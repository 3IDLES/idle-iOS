//
//  CenterSettingCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import CenterFeature
import PresentationCore
import UseCaseInterface

class CenterSettingCoordinator: CenterSettingScreenCoordinatable {
    
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
    
    public func start() {
        let coordinator = CenterSettingScreenCoordinator(
            dependency: .init(
                navigationController: navigationController,
                settingUseCase: injector.resolve(SettingScreenUseCase.self),
                centerProfileUseCase: injector.resolve(CenterProfileUseCase.self)
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func startRemoveCenterAccountFlow() {
        
    }
}
