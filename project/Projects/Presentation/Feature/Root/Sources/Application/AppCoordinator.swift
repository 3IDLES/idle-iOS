//
//  AppCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation
import BaseFeature
import SplashFeature
import AuthFeature
import Core


public class AppCoordinator: BaseCoordinator {
    
    let router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
    public override func start() {
        
        runSplashFlow()
    }
}

extension AppCoordinator {
    
    /// SplashFlow를 시작합니다.
    @discardableResult
    func runSplashFlow() -> SplashCoordinator {
        
        let coordinator = SplashCoordinator(router: router)
        
        coordinator.startFlow = { [weak self] destination in
            
            guard let self else { return }
            
            switch destination {
            case .authPage:
                runAuthFlow()
            case .mainPage(let userType):
                
                switch userType {
                case .center:
                    runCenterMainPageFlow()
                case .worker:
                    runWorkerMainPageFlow()
                }
                
            case .centerCertificatePage:
                runCenterCertificateFlow()
            case .centerMakeProfilePage:
                runCenterMakeProfileFlow()
            }
        }
        
        addChild(coordinator)
        coordinator.start()
        
        return coordinator
    }
    
    
    /// AuthFlow를 시작합니다.
    @discardableResult
    func runAuthFlow() -> AuthCoordinator {
        let coordinator = AuthCoordinator(router: router)
        
        coordinator.startFlow = { [weak self] destination in
            
            guard let self else { return }
            
            switch destination {
            case .centerRegisterPage:
                centerAccountRegisterFlow()
            case .workerRegisterPage:
                return
            case .loginPage:
                return
            }
        }
        
        addChild(coordinator)
        coordinator.start()
        
        return coordinator
    }
    
    
    /// CenterCetrificateFlow를 시작합니다.
    func runCenterCertificateFlow() {
        printIfDebug("CenterCertificate")
    }
    
    
    /// CenterMainFlow를 시작합니다.
    func runCenterMainPageFlow() {
        printIfDebug("CenterMain")
    }
    
    
    /// WorkerMainFlow를 시작합니다.
    func runWorkerMainPageFlow() {
        printIfDebug("WorkerMain")
    }
    
    
    /// CenterMakeProfileFlow를 시작합니다.
    func runCenterMakeProfileFlow() {
        printIfDebug("Center make profile")
    }
}

// MARK: AuthFlow
extension AppCoordinator {
    
    @discardableResult
    func centerAccountRegisterFlow() -> CenterAccountRegisterCoordinator {
        
        let coordinator = CenterAccountRegisterCoordinator(router: router)
        coordinator.startFlow = { [weak self] destination in
            
            guard let self else { return }
            
            switch destination {
            case .centerMainPage:
                runCenterMainPageFlow()
            }
        }
        
        addChild(coordinator)
        coordinator.start()
        
        return coordinator
    }
}
