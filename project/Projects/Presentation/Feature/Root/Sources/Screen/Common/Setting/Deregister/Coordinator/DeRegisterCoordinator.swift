//
//  DeRegisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import Entity
import CenterFeature
import PresentationCore
import UseCaseInterface

public class DeRegisterCoordinator: DeregisterCoordinatable {
    
    public struct Dependency {
        let userType: UserType
        let authUseCase: AuthUseCase
        let navigationController: UINavigationController
        
        public init(userType: UserType, authUseCase: AuthUseCase, navigationController: UINavigationController) {
            self.userType = userType
            self.authUseCase = authUseCase
            self.navigationController = navigationController
        }
    }

    public var childCoordinators: [any Coordinator] = []
    
    public var navigationController: UINavigationController
    
    public var parent: ParentCoordinator?
    
    var viewControllerRef: UIViewController?
    let userType: UserType
    let authUseCase: AuthUseCase
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
        self.authUseCase = dependency.authUseCase
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        showSelectReasonScreen()
    }
    
    public func flowFinished() {
        
    }
    
    public func showSelectReasonScreen() {
        let coordinator: SelectReasonCoordinator = .init(
            dependency: .init(
                userType: userType,
                authUseCase: authUseCase,
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showFinalPasswordScreen(reasons: [Entity.DeregisterReasonVO]) {
    
        let coordinator = PasswordForDeregisterCoordinator(
            dependency: .init(
                authUseCase: authUseCase,
                reasons: reasons,
                navigationController: navigationController
            )
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showFinalPhoneAuthScreen(reasons: [Entity.DeregisterReasonVO]) {
        
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}
