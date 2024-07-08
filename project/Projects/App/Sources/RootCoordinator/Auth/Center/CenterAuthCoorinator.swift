//
//  CenterAuthCoorinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore
import AuthFeature
import ConcreteUseCase
import ConcreteRepository

class CenterAuthCoorinator: ParentCoordinator {
    
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
        
        let coordinator = CenterAuthMainCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
}

extension CenterAuthCoorinator: CenterAuthCoordinatable {
    
    func login() {
        
        let coordinator = CenterLoginCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func findPassword() {
        
        let coordinator = CenterFindPasswordCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func setNewPassword() {
        
        let coordinator = CenterSetNewPasswordCoordinator(
            navigationController: navigationController
        )
        
        coordinator.parent = self
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func register() {
        
        let viewModel = injector.resolve(CenterRegisterViewModel.self)
        
        let coordinator = CenterRegisterCoordinator(viewModel: viewModel, navigationController: navigationController)
        
        coordinator.parent = self
        
        addChildCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func authFinished() {
        
        parent?.authFinished()
    }
}
