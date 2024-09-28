//
//  CanterLoginFlowCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore
import AuthFeature
import Domain

class CanterLoginFlowCoordinator: CanterLoginFlowable {
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }
    
    var childCoordinators: [Coordinator] = []
    
    var parent: AuthCoordinatable?
    
    let navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    func start() {
        login()
    }
}

extension CanterLoginFlowCoordinator: CanterLoginCoordinatable {
    
    func login() {
        let coordinator = CenterLoginCoordinator(
            dependency: .init(
                navigationController: navigationController,
                authUseCase: injector.resolve(AuthUseCase.self)
            )
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    func setNewPassword() {
        
        let coordinator = CenterSetNewPasswordCoordinator(
            dependency: .init(
                navigationController: navigationController,
                authUseCase: injector.resolve(AuthUseCase.self),
                inputValidationUseCase: injector.resolve(AuthInputValidationUseCase.self)
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
