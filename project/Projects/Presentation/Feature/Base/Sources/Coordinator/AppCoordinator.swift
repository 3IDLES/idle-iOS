//
//  AppCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 10/1/24.
//

import Foundation
import BaseFeature
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
