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
import CenterMainPageFeature
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
                workerAccountRegisterFlow()
            case .loginPage:
                centerLoginFlow()
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
    @discardableResult
    func runCenterMainPageFlow() -> CenterMainPageCoordinator {
        let coordinator = CenterMainPageCoordinator(router: router)
        addChild(coordinator)
        coordinator.start()
        return coordinator
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
    
    /// 센터관리자 계정가입을 시작합니다.
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
    
    /// 요양보호사 계정가입을 시작합니다.
    @discardableResult
    func workerAccountRegisterFlow() -> WorkerAccountRegisterCoordinator {
        
        let coordinator = WorkerAccountRegisterCoordinator(router: router)
        coordinator.startFlow = { [weak self] destination in
            
            switch destination {
            case .workerMainPage:
                self?.runWorkerMainPageFlow()
            }
        }
        
        addChild(coordinator)
        coordinator.start()
        
        return coordinator
    }
    
    /// 센터관리자 회원가입을 시작합니다.
    @discardableResult
    func centerLoginFlow() -> CenterLogInCoordinator {
        
        let coordinator = CenterLogInCoordinator(router: router)
        coordinator.startFlow = { [weak self] destination in
            switch destination {
            case .centerMainPage:
                self?.runCenterMainPageFlow()
            }
        }
        
        addChild(coordinator)
        coordinator.start()
        
        return coordinator
    }
    
}

// MARK: Center Main Page
extension AppCoordinator {
    
    func centerPostBoardFlow() {
        
        
    }
}
