//
//  AppCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation
import BaseFeature
import SplashFeature
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
                runCenterMainFlow()
            case .mainPage(let userType):
                runWorkerMainFlow()
            case .centerCertificatePage:
                runCenterCertificateFlow()
            case .centerMakeProfilePage:
                runCenterMakeProfileFlow()
            }
        }
        
        coordinator.start()
        
        
        return coordinator
    }
    
    
    /// AuthFlow를 시작합니다.
    func runAuthFlow() {
        printIfDebug("Auth")
    }
    
    
    /// CenterCetrificateFlow를 시작합니다.
    func runCenterCertificateFlow() {
        printIfDebug("CenterCertificate")
    }
    
    
    /// CenterMainFlow를 시작합니다.
    func runCenterMainFlow() {
        printIfDebug("CenterMain")
    }
    
    
    /// WorkerMainFlow를 시작합니다.
    func runWorkerMainFlow() {
        printIfDebug("WorkerMain")
    }
    
    
    /// CenterMakeProfileFlow를 시작합니다.
    func runCenterMakeProfileFlow() {
        printIfDebug("Center make profile")
    }
}
