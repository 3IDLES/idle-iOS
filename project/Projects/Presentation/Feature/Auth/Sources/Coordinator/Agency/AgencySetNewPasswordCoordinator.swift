//
//  AgencySetNewPasswordCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import PresentationCore
import UIKit


public class AgencySetNewPasswordCoordinator: ChildCoordinator {
    
    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
    public var parent: AgencyAuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func start() {
        
        let viewController = AgencySetNewPasswordController()
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
