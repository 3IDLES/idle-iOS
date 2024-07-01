//
//  AgencyFindPasswordCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

public class AgencyFindPasswordCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: (any PresentationCore.DisposableViewController)?
    
    public var navigationController: UINavigationController
    
    public var parent: AgencyAuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let viewController = AgencyFindPasswordController()
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func coordinatorDidFinish() {
        
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}
