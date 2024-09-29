//
//  WorkerSettingCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import WorkerFeature
import RootFeature
import PresentationCore
import Domain
import Core

class WorkerSettingCoordinaator: WorkerSettingScreenCoordinatable {
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var parent: ParentCoordinator?
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let coordinator = WorkerSettingScreenCoordinator(navigationController: navigationController)
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func startRemoveWorkerAccountFlow() {
        let coordinator = DeRegisterCoordinator(
            userType: .worker,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showMyProfileScreen() {
        let coordinator = WorkerProfileCoordinator(
            profileMode: .myProfile,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
