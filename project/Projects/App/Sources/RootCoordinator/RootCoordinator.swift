//
//  AppCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/28/24.
//

import UIKit
import PresentationCore

class RootCoordinator: ParentCoordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    func start() {
        navigationController.setNavigationBarHidden(true, animated: false)
        
        // 빈화면 VC + VM 구현 예정, 로직에 따라 Auth, CenterMain, WorkerMain을 display
        
        centerMain()
    }
    
    func popViewController() {
        navigationController.popViewController(animated: false)
    }
}
