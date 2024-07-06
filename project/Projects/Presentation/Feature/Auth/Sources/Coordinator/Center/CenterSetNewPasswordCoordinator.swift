//
//  CenterSetNewPasswordCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import PresentationCore
import UIKit


public class CenterSetNewPasswordCoordinator: ChildCoordinator {
    
    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
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
        
        let viewController = CenterSetNewPasswordController()
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
