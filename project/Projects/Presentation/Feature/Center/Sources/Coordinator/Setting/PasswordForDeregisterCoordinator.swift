//
//  PasswordForDeregisterCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class PasswordForDeregisterCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let authUseCase: AuthUseCase
        let reasons: [DeregisterReasonVO]
        let navigationController: UINavigationController
        
        public init(authUseCase: AuthUseCase, reasons: [DeregisterReasonVO], navigationController: UINavigationController) {
            self.authUseCase = authUseCase
            self.reasons = reasons
            self.navigationController = navigationController
        }
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: DeregisterCoordinatable?
    
    public let navigationController: UINavigationController
    let authUseCase: AuthUseCase
    let reasons: [DeregisterReasonVO]
    
    public init(
        dependency: Dependency
    ) {
        self.authUseCase = dependency.authUseCase
        self.reasons = dependency.reasons
        self.navigationController = dependency.navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: PasswordForDeregisterCoordinator.self))")
    }
    
    public func start() {
        let vc = PasswordForDeregisterVC()
        let vm = PasswordForDeregisterVM(
            deregisterReasons: reasons,
            coordinator: self,
            authUseCase: authUseCase
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func flowFinished() {
        parent?.flowFinished()
    }
}

