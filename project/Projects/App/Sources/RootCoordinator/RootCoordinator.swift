//
//  AppCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/28/24.
//

import UIKit
import PresentationCore
import RootFeature
import Domain

class RootCoordinator {
    
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
        
        // Root VC
        let vc = InitialScreenVC()
        let vm = InitialScreenVM(coordinator: self)
        
        vc.bind(viewModel: vm)
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: false)
    }
}
