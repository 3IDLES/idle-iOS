//
//  SplashCoordinator.swift
//  SplashFeature
//
//  Created by choijunios on 10/1/24.
//

import Foundation
import Network
import BaseFeature
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
    
    let router: Router
    
    public var startFlow: ((SplashCoordinatorDestination) -> ())?
    
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
    let checkUserAuthStatePasssed: PublishSubject<Bool> = .init()
    
    
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
    
    func startWithDeepLink() {
        
        
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
public extension SplashCoordinator {
    
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
                    .setAcceptButtonLabelText("앱 종료")
                    .setCancelButtonLabelText("앱 업데이트")
                
                object
                    .cancelButtonClicked
                    .subscribe(onNext: {
                        let url = "itms-apps://itunes.apple.com/app/6670529341";
                        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    })
                    .disposed(by: disposeBag)
                
                object
                    .acceptButtonClicked
                    .subscribe(onNext: {
                        // 어플리케이션 종료
                        exit(0)
                    })
                    .disposed(by: disposeBag)
                
                alertObject.onNext(object)
            }
            .disposed(by: disposeBag)
        
        // 강제업데이트 필요하지 않음
        passForceUpdate
            .onSuccess()
            .bind(to: checkForceUpdatePassed)
            .disposed(by: disposeBag)
    }
}
