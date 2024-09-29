//
//  PasswordForDeregisterCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class PasswordForDeregisterCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var deregisterCoordinator: DeregisterCoordinatable? {
        parent as? DeregisterCoordinatable
    }
    
    public let navigationController: UINavigationController
    let reasons: [String]
    
    public init(
        reasons: [String],
        navigationController: UINavigationController
    ) {
        self.reasons = reasons
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: PasswordForDeregisterCoordinator.self))")
    }
    
    public func start() {
        let vc = PasswordForDeregisterVC()
        let vm = PasswordForDeregisterVM(
            deregisterReasons: reasons,
            coordinator: self
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func popToRoot() {
        deregisterCoordinator?.popToRoot()
    }
    
    public func cancelDeregister() {
        deregisterCoordinator?.cancelDeregister()
    }
}

