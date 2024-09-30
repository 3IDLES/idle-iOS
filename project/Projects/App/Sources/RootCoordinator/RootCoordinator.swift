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
import Core

class RootCoordinator {
    
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    
    var parent: ParentCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
