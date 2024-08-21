//
//  FinalPasswordAuhCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class FinalPasswordAuhCoordinator: ChildCoordinator {
    
    public struct Dependency {
        let authUseCase: AuthUseCase
        let reasons: [DeregisterReasonVO]
        let navigationController: UINavigationController
    }
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: DeRegisterCoordinator?
    
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
        printIfDebug("\(String(describing: FinalPasswordAuhCoordinator.self))")
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

