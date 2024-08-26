//
//  AuthCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import AuthFeature

class AuthCoordinator: ParentCoordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    let navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    public func start() {
        
        let coordinator = SelectAuthTypeCoordinator(
            navigationController: navigationController
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func popViewController() {
        navigationController.popViewController(animated: true)
    }
}
