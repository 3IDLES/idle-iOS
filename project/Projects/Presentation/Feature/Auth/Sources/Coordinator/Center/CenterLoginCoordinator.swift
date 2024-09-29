//
//  CenterLoginCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import Domain
import PresentationCore
import Core

public class CenterLoginCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let navigationController: UINavigationController
        let authUseCase: AuthUseCase
        
        public init(navigationController: UINavigationController, authUseCase: AuthUseCase) {
            self.navigationController = navigationController
            self.authUseCase = authUseCase
        }
    }
    
    public weak var viewControllerRef: UIViewController?

    public var navigationController: UINavigationController
    let authUseCase: AuthUseCase
    
    public var parent: CanterLoginFlowable?
    
    public init(dependency: Dependency) {
        self.navigationController = dependency.navigationController
        self.authUseCase = dependency.authUseCase
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let vm = CenterLoginViewModel(
            coordinator: self,
            authUseCase: authUseCase
        )
        let vc = CenterLoginViewController(viewModel: vm)
        
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension CenterLoginCoordinator {
    
    func showSetNewPasswordScreen() {
        parent?.setNewPassword()
    }
    
    /// Auth가 종료된 경우
    func authFinished() {
        parent?.authFinished()
    }
}
