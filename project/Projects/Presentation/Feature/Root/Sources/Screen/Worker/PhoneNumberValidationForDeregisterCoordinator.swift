//
//  PhoneNumberValidationForDeregisterCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import PresentationCore
import Domain
import Core


class PhoneNumberValidationForDeregisterCoordinator: ChildCoordinator {
    
    let reasons: [String]
    
    weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var deregisterCoordinator: DeregisterCoordinatable? {
        parent as? DeregisterCoordinatable
    }
    
    let navigationController: UINavigationController
    
    
    init(reasons: [String], navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.reasons = reasons
    }
    
    deinit {
        printIfDebug("\(String(describing: PhoneNumberValidationForDeregisterCoordinator.self))")
    }
    
    func start() {
        let vc = PhoneNumberValidationForDeregisterVC()
        let vm = PhoneNumberValidationForDeregisterVM(
            coordinator: self,
            deregisterReasons: reasons
        )
        vc.bind(viewModel: vm)
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    func popToRoot() {
        deregisterCoordinator?.popToRoot()
    }
    
    func cancelDeregister() {
        deregisterCoordinator?.cancelDeregister()
    }
}

