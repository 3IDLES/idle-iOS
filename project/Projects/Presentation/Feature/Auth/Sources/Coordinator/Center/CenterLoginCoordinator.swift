//
//  CenterLoginCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import UseCaseInterface
import PresentationCore

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
        
        let vm = CenterLoginViewModel(authUseCase: authUseCase)
        let vc = CenterLoginViewController(coordinator: self, viewModel: vm)
        
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension CenterLoginCoordinator {
    
    /// 비밀번호 변경창을 종료한 경우
    func findPasswordFinished() {
        popViewController()
    }
    
    /// Auth가 종료된 경우
    func authFinished() {
        parent?.authFinished()
    }
}
