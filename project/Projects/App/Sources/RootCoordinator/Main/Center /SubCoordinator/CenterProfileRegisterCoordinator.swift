//
//  CenterProfileRegisterCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import CenterFeature
import PresentationCore
import Domain
import Core

class CenterProfileRegisterCoordinator: CenterProfileRegisterCoordinatable {
    
    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let coordinator = RegisterCenterInfoCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func registerFinished() {
        
        clearChildren()
        parent?.removeChildCoordinator(self)
    }
}

extension CenterProfileRegisterCoordinator {
    
    func showCompleteScreen() {
        let vc = CenterProfileRegisterCompleteVC(coordinator: self)
        let coordinator = CoordinatorWrapper(
            nav: navigationController,
            vc: vc
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }

    func showPreviewScreen(stateObject: CenterProfileRegisterState) {
        let coordinator = CenterProfileRegisterOverviewCO(
            navigationController: navigationController,
            stateObject: stateObject
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func showMyCenterProfile() {
        let coordinator = CenterProfileCoordinator(
            mode: .myProfile,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.start()
    }
}
