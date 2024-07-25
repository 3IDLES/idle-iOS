//
//  CenterAuthMainCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import PresentationCore
import UIKit

public class CenterAuthMainCoordinator: ChildCoordinator {
    
    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: UIViewController?
    
    public var parent: CenterAuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func coordinatorDidFinish() {
        
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    public func start() {
        
        let viewController = CenterAuthMainViewController()
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
