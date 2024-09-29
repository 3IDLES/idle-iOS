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
        nav: UINavigationController,
        vc: UIViewController,
        animated: Bool = true
    ) {
        self.navigationController = nav
        self.viewControllerRef = vc
        self.animated = animated
    }
    
    public func start() {
        navigationController.pushViewController(viewControllerRef!, animated: animated)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

