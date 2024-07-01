//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import AuthFeature

public class AuthCoordinator: ParentCoordinator {
    
    public var childCoordinators: [Coordinator] = []
    
    public var parent: ParentCoordinator?
    
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
