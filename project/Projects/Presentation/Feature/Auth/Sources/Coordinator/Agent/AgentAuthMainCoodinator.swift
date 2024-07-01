//
//  AgentAuthMainCoodinator.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

public class AgentAuthMainCoodinator: ChildCoordinator {

    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
    public var parent: AgentAuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
            
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("deinit \(SelectAuthTypeCoordinator.self)")
    }
    
    public func start() {
        
        let viewController = AgentAuthMainViewController()
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
    
    func register() {
        
        parent?.register()
    }
}


