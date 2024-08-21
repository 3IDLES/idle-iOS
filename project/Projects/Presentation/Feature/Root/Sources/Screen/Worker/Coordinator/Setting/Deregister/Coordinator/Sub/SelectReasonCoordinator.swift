//
//  SelectReasonCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import UseCaseInterface
import Entity

public class SelectReasonCoordinator: ChildCoordinator {
    
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
    
    public weak var viewControllerRef: UIViewController?
    public var navigationController: UINavigationController
    public weak var parent: DeregisterCoordinatable?
    
    let userType: UserType
    let authUseCase: AuthUseCase
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
        self.authUseCase = dependency.authUseCase
        self.navigationController = dependency.navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: SelectReasonCoordinator.self))")
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
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func showPasswordAuthScreen(reasons: [DeregisterReasonVO]) {
        parent?.showFinalPasswordScreen(reasons: reasons)
    }
    
    public func showPhoneNumberAuthScreen() {
        
    }
}

