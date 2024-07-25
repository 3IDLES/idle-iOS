//
//  SelectAuthTypeCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

public class SelectAuthTypeCoordinator: ChildCoordinator {
    
    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: UIViewController?
    
    public var parent: AuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let viewController = SelectAuthTypeViewController()
        viewController.coordinator = self
        viewControllerRef = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

extension SelectAuthTypeCoordinator {
    
    func authWorker() {
        
        parent?.auth(type: .worker)
    }
    
    func authCenter() {
        
        parent?.auth(type: .center)
    }
}
