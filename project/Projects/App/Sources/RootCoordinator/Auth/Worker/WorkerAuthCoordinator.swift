//
//  WorkerAuthCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import AuthFeature

class WorkerAuthCoordinator: ParentCoordinator {
    
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
        
        let coordinator = WorkerAuthMainCoodinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension WorkerAuthCoordinator: WorkerAuthCoordinatable {
    
    func register() {
        
        let coordinator = WorkerRegisterCoordinator(
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
