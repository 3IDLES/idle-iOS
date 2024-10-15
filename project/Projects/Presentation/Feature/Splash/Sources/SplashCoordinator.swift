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
    @Injected var router: RouterProtocol
    @Injected var remoteConfig: RemoteConfigService
    
    public var startFlow: ((SplashCoordinatorDestination) -> ())!
    
    public weak var delegate: SplashCoordinatorDelegate?
    
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
    
    public init() { }
    
    public override func start() {
         
        let module = SplashPageVC()
        
        router.setRootModuleTo(
            module: module
        ) { [weak self] in
            self?.onFinish?()
        }
        
        checkNetworkFlow()
        checkForceUpdateFlow()
        checkUserFlow()
        startNeworkMonitoring()
        
        Observable
            .zip(
                networkCheckingPassed,
                forceUpdateCheckingPassed,
                userAuthStateCheckingPasssed
            )
            .unretained(self)
            .subscribe(onNext: { (object, arg1) in
                let (_, _, userType) = arg1
                object.startFlow(.mainPage(userType: userType))
                object.delegate?.splashCoordinator(satisfiedAllCondition: true)
            })
            .disposed(by: disposeBag)
    }
    
    /// 딥링크 단계를 수행합니다.
    /// 필수 인증 단계를 통과하지 못하면 false를 반환합니다.
    public func startWithDeepLink(successCompletion: @escaping (UserType) -> ()) {
        
        let module = SplashPageVC()
        
        router.push(
            module: module,
            animated: false
        )
        
        checkNetworkFlow()
        checkForceUpdateFlow()
        checkUserFlow()
        startNeworkMonitoring()
        
        Observable
            .zip(
                networkCheckingPassed,
                forceUpdateCheckingPassed,
                userAuthStateCheckingPasssed
            )
            .unretained(self)
            .subscribe(onNext: { (object, arg1) in
                let (_, _, userType) = arg1
                
                successCompletion(userType)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: 네트워크 확인
private extension SplashCoordinator {
    
    func checkNetworkFlow() {
        
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
            .unretained(self)
            .flatMap({ (obj, _) in
                obj.remoteConfig.fetchRemoteConfig()
            })
            .compactMap { $0.value }
            .unretained(self)
            .map { (obj, isConfigFetched) in
                
                if !isConfigFetched {
                    
                }
                
                do {
                    let config: ForceUpdateInfo = try obj.remoteConfig.getJSONProperty(key: "forceUpdate_iOS")
                    return config
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            .map { info in
                
                let minAppVersion = info.minVersion
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                
                printIfDebug("앱 버전: \(appVersion) 최소앱버전: \(minAppVersion)")
                
                return minAppVersion <= appVersion
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
                    .setCancelAction(.init(
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
    
    func checkUserFlow() {
        
        let seekLocalUser = forceUpdateCheckingPassed
            .map { [userInfoLocalRepository] _ in
                
                return userInfoLocalRepository.getUserType()
            }
            .share()
        
        let userFound = seekLocalUser.compactMap({ $0 })
        let userNotFound = seekLocalUser.filter({ $0 == nil })
        
        userNotFound
            .mapToVoid()
            .subscribe(onNext: { [weak self] in
                self?.startFlow(.authPage)
            })
            .disposed(by: disposeBag)
        
        userFound
            .unretained(self)
            .subscribe(onNext: { (object, userType) in
                switch userType {
                case .center:
                    object.checkCenterFlow()
                case .worker:
                    object.checkWorkerFlow()
                }
            })
            .disposed(by: disposeBag)
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
    
    func checkCenterFlow() {
        
        let centerJoinStatusResult = authUseCase
            .checkCenterJoinStatus()
            .asObservable()
            .share()
        
        let centerJoinStatusSuccess = centerJoinStatusResult.compactMap { $0.value }
        let centerJoinStatusFailure = centerJoinStatusResult.compactMap { $0.error }
        
        centerJoinStatusFailure
            .unretained(self)
            .subscribe(onNext: { (object, error) in
                
                switch error {
                case .tokenExpiredException, .tokenNotFound:
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
        
        let checkProfileRegisterResult = centerJoinStatusSuccess
            .unretained(self)
            .compactMap { (object, info) -> CenterJoinStatusInfoVO? in
                
                switch info.centerManagerAccountStatus {
                case .approved:
                    return info
                case .pending, .new:
                    
                    // 센터인증화면으로 이동
                    object.startFlow(.authPage)
                    
                    return nil
                }
            }
            .flatMap { [centerProfileUseCase] _ in
                centerProfileUseCase
                    .getProfile(mode: .myProfile)
            }
            .share()
        
        let profileExists = checkProfileRegisterResult.compactMap { $0.value }
        let profileDoentExistOrError = checkProfileRegisterResult.compactMap { $0.error }
        
        profileDoentExistOrError
            .unretained(self)
            .subscribe(onNext: { (object, error) in
                
                switch error {
                case .centerNotFoundException:
                    
                    // 센터가 없는 경우 -> 프로필이 등록되지 않음
                    // 프로필 등록화면으로 이동
                    object.startFlow(.centerMakeProfilePage)
                    
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
        
        // 프로필이 존재함으로 메인화면으로 이동
        profileExists
            .unretained(self)
            .map { (object, profileVO) -> UserType in
                
                // 불로온 정보를 로컬에 저장
                object.userInfoLocalRepository.updateCurrentCenterData(vo: profileVO)
                
                return .center
            }
            .bind(to: userAuthStateCheckingPasssed)
            .disposed(by: disposeBag)
    }
}

public protocol SplashCoordinatorDelegate: AnyObject {
    
    func splashCoordinator(satisfiedAllCondition: Bool)
}
