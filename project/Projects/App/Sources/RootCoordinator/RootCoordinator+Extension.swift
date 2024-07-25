//
//  RootCoordinator+Extension.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import Foundation
import AuthFeature

extension RootCoordinator {
    
    func auth() {
        
        let authCoordinator = AuthCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
        
        authCoordinator.start()
    }
    
    /// 요양보호사 메인화면을 실행합니다.
    func workerMain() {
        
        let coordinator = WorkerMainCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
//        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    /// 센터 메인화면을 시작합니다.
    func centerMain() {
        
        
    }
}
