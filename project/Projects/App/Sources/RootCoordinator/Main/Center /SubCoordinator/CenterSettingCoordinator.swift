//
//  CenterSettingCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import CenterFeature
import RootFeature
import PresentationCore
import Domain
import Core

class CenterSettingCoordinator: CenterSettingCoordinatable {
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var parent: ParentCoordinator?
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let coordinator = CenterSettingScreenCoordinator(
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func startRemoveCenterAccountFlow() {
        let coordinator = DeRegisterCoordinator(
            userType: .center,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showMyCenterProfile() {
        let coordinator = CenterProfileCoordinator(
            mode: .myProfile,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
