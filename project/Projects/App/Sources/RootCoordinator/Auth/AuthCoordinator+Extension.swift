//
//  AuthCoordinator+Extension.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import Foundation
import AuthFeature
import PresentationCore
import UseCaseInterface
import RepositoryInterface

extension AuthCoordinator: AuthCoordinatable {
    
    public func registerAsWorker() {
        
        let coordinator = WorkerRegisterCoordinator(
            dependency: .init(
                navigationController: navigationController,
                inputValidationUseCase: injector.resolve(AuthInputValidationUseCase.self),
                authUseCase: injector.resolve(AuthUseCase.self)
            )
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func registerAsCenter() {
        let coordinator = CenterRegisterCoordinator(
            dependency: .init(
                navigationController: navigationController,
                inputValidationUseCase: injector.resolve(AuthInputValidationUseCase.self),
                authUseCase: injector.resolve(AuthUseCase.self)
            )
        )
        coordinator.parent = self
        addChildCoordinator(coordinator)
        coordinator.start()
    }
    
    public func startCenterLoginFlow() {
        
        let coordinator = CanterLoginFlowCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }

    public func authFinished() {
        
        clearChildren()
        
        parent?.removeChildCoordinator(self)
    }
}
