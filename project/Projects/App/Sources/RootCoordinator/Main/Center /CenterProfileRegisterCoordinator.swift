//
//  CenterProfileRegisterCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import CenterFeature
import PresentationCore
import UseCaseInterface

class CenterProfileRegisterCoordinator: CenterProfileRegisterCoordinatable {

    var childCoordinators: [Coordinator] = []
    
    var parent: ParentCoordinator?
    
    var navigationController: UINavigationController
    let injector: Injector
    
    init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.injector = dependency.injector
    }
    
    func start() {
        
        let viewModel = RegisterCenterInfoVM(
            profileUseCase: injector.resolve(CenterProfileUseCase.self)
        )
        
        let coordinator = RegisterCenterInfoCoordinator(
            viewModel: viewModel,
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
    
    func showOverViewScreen() {
        printIfDebug("test test test")
        
        registerFinished()
    }
}
