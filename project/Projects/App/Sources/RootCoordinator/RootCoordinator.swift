//
//  AppCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/28/24.
//

import UIKit
import PresentationCore

class RootCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        navigationController.navigationBar.isHidden = true
        
        let coordinator = TestMainTabBarCoodinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func popViewController() {
        navigationController.popViewController(animated: false)
    }
}
