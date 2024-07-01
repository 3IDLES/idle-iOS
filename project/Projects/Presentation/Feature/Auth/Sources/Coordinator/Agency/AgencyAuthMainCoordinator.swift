//
//  AgencyAuthMainCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import PresentationCore
import UIKit

public class AgencyAuthMainCoordinator: ChildCoordinator {
    
    public var navigationController: UINavigationController
    
    public weak var viewControllerRef: DisposableViewController?
    
    public var parent: AgencyAuthCoordinatable?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func coordinatorDidFinish() {
        
        viewControllerRef?.cleanUp()
        
        parent?.removeChildCoordinator(self)
    }
    
    public func start() {
        
        let viewController = AgencyAuthMainViewController()
        viewController.coordinator = self
        
        viewControllerRef = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
