//
//  AgencyAuthCoorinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore
import AuthFeature

class AgencyAuthCoorinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var parent: AuthCoordinatable?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    func start() {
        
        let coordinator = AgencyAuthMainCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension AgencyAuthCoorinator: AgencyAuthCoordinatable {
    
    func login() {
        
        let coordinator = AgencyLoginCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func findPassword() {
        
        let coordinator = AgencyFindPasswordCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func setNewPassword() {
        
        let coordinator = AgencySetNewPasswordCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func register() {
        
        let coordinator = AgencyRegisterCoordinator(
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
