//
//  AppCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/28/24.
//

import UIKit
import PresentationCore

struct Dependency {
    let navigationController: UINavigationController
    let injector: Injector
}

class RootCoordinator: ParentCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        
        workerMain()
    }
    
    func popViewController() {
        navigationController.popViewController(animated: false)
    }
}
