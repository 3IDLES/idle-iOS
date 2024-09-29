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
    
    struct Dependency {
        let parent: CenterMainCoordinatable
        let injector: Injector
        let navigationController: UINavigationController
    }
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var parent: CenterMainCoordinatable?
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
        self.parent = dependency.parent
    }
    
    func start() {
        let coordinator = CenterSettingScreenCoordinator(
            dependency: .init(
                navigationController: navigationController,
                settingUseCase: injector.resolve(SettingScreenUseCase.self)
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func startRemoveCenterAccountFlow() {
        let coordinator = DeRegisterCoordinator(
            dependency: .init(
                userType: .center,
                settingUseCase: injector.resolve(SettingScreenUseCase.self),
                inputValidationUseCase: injector.resolve(AuthInputValidationUseCase.self),
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    func showMyCenterProfile() {
        let coordinator = CenterProfileCoordinator(
            dependency: .init(
                mode: .myProfile,
                profileUseCase: injector.resolve(CenterProfileUseCase.self),
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
