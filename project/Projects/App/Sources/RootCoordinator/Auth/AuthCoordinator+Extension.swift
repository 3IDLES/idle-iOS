//
//  AuthCoordinator+Extension.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import Foundation
import AuthFeature
import PresentationCore
import Domain
import BaseFeature

extension AuthCoordinator: AuthCoordinatable {
    
    public func registerAsWorker() {
        
        let coordinator = WorkerRegisterCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func registerAsCenter() {
        
    }
    
    public func showCompleteScreen(ro: AnonymousCompleteVCRenderObject) {
        let vc = AnonymousCompleteVC()
        vc.applyRO(ro)
        
        let coordinator = CoordinatorWrapper(
            nav: navigationController,
            vc: vc
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func startCenterLoginFlow() {
        
        let coordinator = CanterLoginFlowCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }

    public func authFinished() {
        clearChildren()
        parent?.removeChildCoordinator(self)
    }
}
