//
//  CoordinatorWrapper.swift
//  PresentationCore
//
//  Created by choijunios on 8/29/24.
//

import UIKit


public class CoordinatorWrapper: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    
    public let navigationController: UINavigationController
    
    let animated: Bool
    
    public init(
        parent: ParentCoordinator,
        nav: UINavigationController,
        vc: UIViewController,
        animated: Bool = true
    ) {
        self.parent = parent
        self.navigationController = nav
        self.viewControllerRef = vc
        self.animated = animated
        
        parent.addChildCoordinator(self)
    }
    
    public func start() {
        navigationController.pushViewController(viewControllerRef!, animated: animated)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

