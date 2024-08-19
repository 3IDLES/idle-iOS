//
//  CenterSettingCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import PresentationCore

public class CenterSettingCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = TestSettingVC()
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        
    }
}
