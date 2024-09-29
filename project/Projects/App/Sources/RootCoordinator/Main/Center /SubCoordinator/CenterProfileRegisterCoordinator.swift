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
    
    struct Dependency {
        let navigationController: UINavigationController
        let injector: Injector
    }

    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    var navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    func start() {
        
        let coordinator = RegisterCenterInfoCoordinator(
            profileUseCase: injector.resolve(CenterProfileUseCase.self),
            navigationController: navigationController
        )
        
        addChildCoordinator(coordinator)
        coordinator.parent = self
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
            parent: self,
            nav: navigationController,
            vc: vc
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }

    func showPreviewScreen(stateObject: CenterProfileRegisterState) {
        let coordinator = CenterProfileRegisterOverviewCO(
            dependency: .init(
                navigationController: navigationController,
                stateObject: stateObject,
                profileUseCase: injector.resolve(CenterProfileUseCase.self)
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
