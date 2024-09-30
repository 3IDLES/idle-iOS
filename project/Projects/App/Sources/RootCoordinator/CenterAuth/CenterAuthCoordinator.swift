//
//  CenterAuthCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 9/7/24.
//

import UIKit
import PresentationCore
import Core

class CenterAuthCoordinator: ParentCoordinator {
    
    weak var parent: ParentCoordinator?
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
    }
    
    func start() {
        
    }
}
