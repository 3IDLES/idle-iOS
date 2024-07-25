//
//  SettingCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import PresentationCore

public class SettingCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = SettingVC()
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        
    }
}
