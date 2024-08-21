//
//  DeRegisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import Entity
import PresentationCore

public class DeRegisterCoordinator: DeregisterCoordinator {
    
    public struct Dependency {
        let userType: UserType
        let navigationController: UINavigationController
    }

    public var childCoordinators: [any Coordinator] = []
    
    public var navigationController: UINavigationController
    
    var viewControllerRef: UIViewController?
    let userType: UserType
    
    public init(dependency: Dependency) {
        self.userType = dependency.userType
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
    
    public func showFinalPasswordScreen(reasons: [Entity.DeregisterReasonVO]) {
        
    }
    
    public func showFinalPhoneAuthScreen(reasons: [Entity.DeregisterReasonVO]) {
        
    }
    
}
