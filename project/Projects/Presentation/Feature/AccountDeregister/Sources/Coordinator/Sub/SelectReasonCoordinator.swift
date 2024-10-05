//
//  SelectReasonCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class SelectReasonCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public var navigationController: UINavigationController
    public weak var parent: ParentCoordinator?
    var deregisterCoordinator: DeregisterCoordinatable? {
        parent as? DeregisterCoordinatable
    }
    
    let userType: UserType
    
    public init(userType: UserType, navigationController: UINavigationController) {
        self.userType = userType
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: SelectReasonCoordinator.self))")
    }
    
    public func start() {
        var vm: DeregisterReasonVMable!
        switch userType {
        case .center:
            vm = CenterDeregisterReasonsVM()
        case .worker:
            vm = WorkerDeregisterReasonsVM()
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
    
    public func showPasswordAuthScreen(reasons: [String]) {
        deregisterCoordinator?.showFinalPasswordScreen(reasons: reasons)
    }
    
    public func showPhoneNumberAuthScreen(reasons: [String]) {
        deregisterCoordinator?.showFinalPhoneAuthScreen(reasons: reasons)
    }
}

