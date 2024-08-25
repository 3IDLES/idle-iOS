//
//  DeRegisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import Entity
import PresentationCore
import CenterFeature
import UseCaseInterface

public class DeRegisterCoordinator: DeregisterCoordinatable {
    
    public struct Dependency {
        let userType: UserType
        let settingUseCase: SettingScreenUseCase
        let navigationController: UINavigationController
        
        public init(userType: UserType, settingUseCase: SettingScreenUseCase, navigationController: UINavigationController) {
            self.userType = userType
            self.settingUseCase = settingUseCase
            self.navigationController = navigationController
        }
    }

    public var childCoordinators: [any Coordinator] = []
    
    public var navigationController: UINavigationController
    
    public var parent: ParentCoordinator?
    
    var viewControllerRef: UIViewController?
    let userType: UserType
    let settingUseCase: SettingScreenUseCase
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
        self.settingUseCase = dependency.settingUseCase
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        showSelectReasonScreen()
    }
    
    public func showSelectReasonScreen() {
        let coordinator: SelectReasonCoordinator = .init(
            dependency: .init(
                userType: userType,
                settingUseCase: settingUseCase,
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
                settingUseCase: settingUseCase,
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
    
    public func cancelDeregister() {
        clearChildren()
        parent?.removeChildCoordinator(self)
    }
}
