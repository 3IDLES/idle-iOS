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
    
}

extension AppCoordinator {
    
    /// SplashFlow를 시작합니다.
    func runSplashFlow() {
        
        let coordinator = SplashCoordinator(router: router)
        
    }
    
    
    /// AuthFlow를 시작합니다.
    func runAuthFlow() {
        
    }
    
    
    /// CenterCetrificateFlow를 시작합니다.
    func runCenterCertificateFlow() {
        
        
    }
    
    
    /// CenterMainFlow를 시작합니다.
    func runCenterMainFlow() {
            
    }
    
    
    /// WorkerMainFlow를 시작합니다.
    func runWorkerMainFlow() {
        
        
    }
}
