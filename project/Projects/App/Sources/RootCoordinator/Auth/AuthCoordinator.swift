//
//  AuthCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import AuthFeature
import Core

class AuthCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    public func start() {
        
        let coordinator = SelectAuthTypeCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func popViewController() {
        navigationController.popViewController(animated: true)
    }
}
