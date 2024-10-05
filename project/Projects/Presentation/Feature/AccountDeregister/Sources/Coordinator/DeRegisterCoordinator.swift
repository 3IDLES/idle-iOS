//
//  DeRegisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import CenterFeature
import Domain

public class DeRegisterCoordinator: DeregisterCoordinatable {
    
    public var childCoordinators: [any Coordinator] = []
    
    public var navigationController: UINavigationController
    
    public var parent: ParentCoordinator?
    
    var viewControllerRef: UIViewController?
    let userType: UserType
    
    public init(userType: UserType, navigationController: UINavigationController) {
        self.userType = userType
        self.navigationController = navigationController
    }
    
    public func start() {
        showSelectReasonScreen()
    }
    
    public func showSelectReasonScreen() {
        let coordinator: SelectReasonCoordinator = .init(
            userType: userType,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showFinalPasswordScreen(reasons: [String]) {
    
        let coordinator = PasswordForDeregisterCoordinator(
            reasons: reasons,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func showFinalPhoneAuthScreen(reasons: [String]) {
        let coordinator = PhoneNumberValidationForDeregisterCoordinator(
            reasons: reasons,
            navigationController: navigationController
        )
        addChildCoordinator(coordinator)
        coordinator.parent = self
        coordinator.start()
    }
    
    public func cancelDeregister() {
        clearChildren()
        parent?.removeChildCoordinator(self)
    }
    
    public func popToRoot() {
        NotificationCenter.default.post(name: .popToInitialVC, object: nil)
    }
}
