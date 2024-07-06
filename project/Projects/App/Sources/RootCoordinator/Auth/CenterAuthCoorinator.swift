//
//  CenterAuthCoorinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore
import AuthFeature

class CenterAuthCoorinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var parent: AuthCoordinatable?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    func start() {
        
        let coordinator = CenterAuthMainCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension CenterAuthCoorinator: CenterAuthCoordinatable {
    
    func login() {
        
        let coordinator = CenterLoginCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func findPassword() {
        
        let coordinator = CenterFindPasswordCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func setNewPassword() {
        
        let coordinator = CenterSetNewPasswordCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func register() {
        
        let coordinator = CenterRegisterCoordinator(
            viewModel: CenterRegisterViewModel(),
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
