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
import UseCaseInterface

class WorkerSettingCoordinaator: WorkerSettingScreenCoordinatable {
    
    struct Dependency {
        let parent: WorkerMainCoordinator
        let injector: Injector
        let navigationController: UINavigationController
    }
    
    var childCoordinators: [any PresentationCore.Coordinator] = []
    
    weak var parent: WorkerMainCoordinator?
    
    weak var viewControllerRef: UIViewController?
    
    var navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
        self.parent = dependency.parent
    }
    
    public func start() {
        let coordinator = WorkerSettingScreenCoordinator(
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
    
    public func startRemoveWorkerAccountFlow() {
        let coordinator = DeRegisterCoordinator(
            dependency: .init(
                userType: .worker,
                settingUseCase: injector.resolve(SettingScreenUseCase.self),
                inputValidationUseCase: injector.resolve(AuthInputValidationUseCase.self),
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
}
