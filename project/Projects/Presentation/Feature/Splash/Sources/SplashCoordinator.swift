//
//  SplashCoordinator.swift
//  SplashFeature
//
//  Created by choijunios on 10/1/24.
//

import UIKit
import Network
import BaseFeature
import DSKit
import Domain
import Core


import RxSwift
import FirebaseCrashlytics
import FirebaseRemoteConfig

public enum SplashCoordinatorDestination {
    case authPage
    case mainPage(userType: UserType)
    case centerCertificatePage
    case centerMakeProfilePage
}

public class SplashCoordinator: BaseCoordinator {
    
    // DI
    @Injected var authUseCase: AuthUseCase
    @Injected var workerProfileUseCase: WorkerProfileUseCase
    @Injected var centerProfileUseCase: CenterProfileUseCase
    @Injected var userInfoLocalRepository: UserInfoLocalRepository
    
    let router: Router
    
    public var startFlow: ((SplashCoordinatorDestination) -> ())!
    
    // #1. 네트워크 연결상태 확인
    private let networkCheckingPassed: PublishSubject<Void> = .init()
    
    private let networkMonitor: NWPathMonitor = .init()
    private let networkMonitoringQueue = DispatchQueue.global(qos: .background)
    private let networkConnectionState: PublishSubject<Bool> = .init()
    
    // #2. 강제 업데이트 확인
    let forceUpdateCheckingPassed: PublishSubject<Void> = .init()
    
    // #3. 유저 인증정보 확인
    /// - 요양보호사 토큰이 유효한가?
    /// - 센터토큰이 유효한가?
    /// - 센터 인증정보가 있는가?
    /// - 센터 프로필 정보가 있는가?
    let userAuthStateCheckingPasssed: PublishSubject<UserType> = .init()
    
    
    let disposeBag = DisposeBag()
    
    public init(router: Router) {
        self.router = router
    }
    
    public override func start() {
         
        let viewModel = SplashPageVM()
        
        viewModel.startAuthFlow = { [weak self] in
            self?.startFlow?(.authPage)
        }
        
        viewModel.startCenterMainFlow = { [weak self] in
            self?.startFlow?(.mainPage(userType: .center))
        }
        
        viewModel.startWorkerMainFlow = { [weak self] in
            self?.startFlow?(.mainPage(userType: .worker))
        }
        
        viewModel.startCenterCertificateFlow = { [weak self] in
            self?.startFlow?(.centerCertificatePage)
        }
        
        viewModel.startMakingCenterProfileFlow = { [weak self] in
            self?.startFlow?(.centerMakeProfilePage)
        }
        
        let viewController = SplashPageVC(viewModel: viewModel)
        
        router.push(
            module: viewController,
            animated: false
        )
    }
    
    /// 딥링크 단계를 수행합니다.
    /// 필수 인증 단계를 통과하지 못하면 false를 반환합니다.
    func startWithDeepLink(completion: @escaping (Bool) -> ()) {
        
        
    }
    
}

// MARK: 네트워크 확인
private extension SplashCoordinator {
    
    func networkCheckingFlow() {
        
        // 네트워가 연결된 상태
        networkConnectionState
            .onSuccess()
            .take(1)
            .bind(to: networkCheckingPassed)
            .disposed(by: disposeBag)
        
        // 네트워크가 연결되지 않음
        networkConnectionState
            .onFailure { [router] in
                
                let alertObject = DefaultAlertObject()
                
                alertObject
                    .setTitle("인터넷 연결이 불안정해요")
                    .setDescription("Wi-Fi 또는 셀룰러 데이터 연결을 확인한 후 다시 시도해 주세요.")
                    .addAction(.init(
                        titleName: "다시 시도하기") {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                                guard let self else { return }
                                
                                let status = self.networkMonitor.currentPath.status
                                
                                self.networkConnectionState
                                    .onNext(status == .requiresConnection ||
                                            status == .satisfied
                                    )
                            }
                        }
                    )
                
                router
                    .presentDefaultAlertController(object: alertObject)
            }
            .disposed(by: disposeBag)
    }
    
    func startNeworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.checkNetworkStatusAndPublish(status: path.status, delay: 0)
            }
        }
        networkMonitor.start(queue: networkMonitoringQueue)
    }
    
    func checkNetworkStatusAndPublish(status: NWPath.Status, delay: Int) {
        networkConnectionState.onNext(
            status == .requiresConnection ||
            status == .satisfied
        )
    }
}

// MARK: 강제업데이트 유무 확인하기
private extension SplashCoordinator {
    
    func checkForceUpdateFlow() {
        
        let passForceUpdate = networkCheckingPassed
            .flatMap({ _ in
                RemoteConfigService.shared.fetchRemoteConfig()
            })
            .compactMap { $0.value }
            .map { isConfigFetched in
                
                if !isConfigFetched {
                    Crashlytics.crashlytics().log("Remote Config fetch실패")
                }
                
                guard let config = RemoteConfigService.shared.getForceUpdateInfo() else {
                    // ‼️ Config로딩 불가시 크래쉬
                    Crashlytics.crashlytics().log("Remote Config획득 실패")
                    fatalError("Remote Config fetching에러")
                }
                
                return config
            }
            .map { info in
                
                let minAppVersion = info.minVersion
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                
                printIfDebug("앱 버전: \(appVersion) 최소앱버전: \(minAppVersion)")
                
                return minAppVersion > appVersion
            }
            .share()
        
        // 강제업데이트 필요
        passForceUpdate
            .onFailure { [weak self] in
                
                guard let self else { return }
                
                // 네트워크 연결되지 않음
                let object = IdleAlertObject()
                    .setTitle("최신 버전의 앱이 있어요")
                    .setDescription("유저분들의 의견을 반영해 앱을 더 발전시켰어요.\n보다 좋은 서비스를 만나기 위해, 업데이트해주세요.")
                    .setAcceptAction(.init(
                        name: "앱 종료",
                        action: { exit(0) })
                    )
                    .setAcceptAction(.init(
                        name: "앱 업데이트",
                        action: {
                            let url = "itms-apps://itunes.apple.com/app/6670529341";
                            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:])
                            }
                        })
                    )
                
                router.presentIdleAlertController(
                    type: .red,
                    object: object
                )
            }
            .disposed(by: disposeBag)
        
        // 강제업데이트 필요하지 않음
        passForceUpdate
            .onSuccess()
            .bind(to: forceUpdateCheckingPassed)
            .disposed(by: disposeBag)
    }
}

// MARK: 로컬에 저장된 유저가 있는지 확인
private extension SplashCoordinator {
    
    func checkLocalUser() {
        
        let seekLocalUser = forceUpdateCheckingPassed
            .map { [userInfoLocalRepository] _ in
                
                return userInfoLocalRepository.getUserType()
            }
        
        let userFound = seekLocalUser.compactMap({ $0 })
        let userNotFound = seekLocalUser.filter({ $0 == nil })
        
        userNotFound
            .mapToVoid()
            .subscribe(onNext: { [weak self] in
                self?.startFlow(.authPage)
            })
            .disposed(by: disposeBag)
        
        
        let workerUser = userFound.filter({ $0 == .worker })
        let centerUser = userFound.filter({ $0 == .center })
           
    }
    
    func checkWorkerFlow() {
        
        let profileFetchResult = workerProfileUseCase
            .getFreshProfile(mode: .myProfile)
            .asObservable()
            .share()
        
        let profileFetchSuccess = profileFetchResult.compactMap { $0.value }
        let profileFetchFailure = profileFetchResult.compactMap { $0.error }
        
        profileFetchSuccess
            .unretained(self)
            .map { (object, profileVO) -> UserType in
                
                // 불로온 정보 로컬에 저장
                object.userInfoLocalRepository.updateCurrentWorkerData(vo: profileVO)
                
                return .worker
            }
            .bind(to: userAuthStateCheckingPasssed)
            .disposed(by: disposeBag)
            
        profileFetchFailure
            .unretained(self)
            .subscribe(onNext: { (object, error) in
                
                switch error {
                case .tokenExpiredException:
                    // 토큰이 만료된 경우
                    object.startFlow(.authPage)
                default:
                    // 토큰과 무관한 에러상황
                    let alertVO = DefaultAlertObject()
                    alertVO
                        .setTitle("초기화면 오류")
                        .setDescription(error.message)
                        .addAction(.init(
                            titleName: "앱 종료",
                            action: { exit(1) }
                        ))
                }
            })
            .disposed(by: disposeBag)
    }
}

