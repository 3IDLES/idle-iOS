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


import RxSwift

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
    private let cehckNetworkPassed: PublishSubject<Void> = .init()
    
    private let networkMonitor: NWPathMonitor = .init()
    private let networkMonitoringQueue = DispatchQueue.global(qos: .background)
    private let networkConnectionState: PublishSubject<Bool> = .init()
    
    // #2. 강제 업데이트 확인
    let checkForceUpdatePassed: PublishSubject<Bool> = .init()
    
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
            .bind(to: cehckNetworkPassed)
            .disposed(by: disposeBag)
        
        // 네트워크가 연결되지 않음
        networkConnectionState
            .onFailure {
                
                // 재시도 Alert
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

