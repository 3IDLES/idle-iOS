//
//  AgentAuthCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import AuthFeature

class AgentAuthCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var parent: AuthCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    func start() {
        
        let coordinator = AgentAuthMainCoodinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension AgentAuthCoordinator: AgentAuthCoordinatable {
    
    func register() {
        
        let coordinator = AgentRegisterCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func authFinished() {
        
        parent?.authFinished()
    }
}
