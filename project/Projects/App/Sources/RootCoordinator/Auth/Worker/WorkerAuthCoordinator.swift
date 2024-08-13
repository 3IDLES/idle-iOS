//
//  WorkerAuthCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import AuthFeature

class WorkerAuthCoordinator: ParentCoordinator {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    let injector: Injector
    
    var parent: AuthCoordinator?
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    func start() {
        
        let coordinator = WorkerAuthMainCoodinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension WorkerAuthCoordinator: WorkerAuthCoordinatable {
    
    func register() {
        
        let coordinator = WorkerRegisterCoordinator(
            navigationController: navigationController,
            viewModel: WorkerRegisterViewModel(
                inputValidationUseCase: injector.resolve(AuthInputValidationUseCase.self),
                authUseCase: injector.resolve(AuthUseCase.self)
            )
        )
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func authFinished() {
        
        parent?.authFinished()
    }
}
