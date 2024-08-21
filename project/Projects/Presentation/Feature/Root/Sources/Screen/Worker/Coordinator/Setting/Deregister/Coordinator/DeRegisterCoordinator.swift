//
//  DeRegisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import Entity
import PresentationCore
import UseCaseInterface

public class DeRegisterCoordinator: DeregisterCoordinator {
    
    public struct Dependency {
        let userType: UserType
        let parent: ParentCoordinator
        let authUseCase: AuthUseCase
        let navigationController: UINavigationController
    }

    public var childCoordinators: [any Coordinator] = []
    
    public var navigationController: UINavigationController
    
    public var parent: ParentCoordinator?
    
    var viewControllerRef: UIViewController?
    let userType: UserType
    let authUseCase: AuthUseCase
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
        self.parent = dependency.parent
        self.authUseCase = dependency.authUseCase
        self.navigationController = dependency.navigationController
    }
    
    public func start() {
        var vm: DeregisterReasonVMable!
        switch userType {
        case .center:
            vm = CenterDeregisterReasonsVM(coordinator: self)
        case .worker:
            fatalError()
        }
        
        let vc = DeregisterReasonVC()
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func flowFinished() {
        
    }
    
    public func showFinalPasswordScreen(reasons: [Entity.DeregisterReasonVO]) {
    
        let coordinator = FinalPasswordAuhCoordinator(
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
