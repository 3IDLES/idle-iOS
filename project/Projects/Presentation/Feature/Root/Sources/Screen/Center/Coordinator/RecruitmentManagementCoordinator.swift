//
//  RecruitmentManagementCoordinator.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import PresentationCore

public class RecruitmentManagementCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    
    public var navigationController: UINavigationController
    
    public weak var parent: CenterMainCoordinatable?
    
    public init(
        parent: CenterMainCoordinatable,
        navigationController: UINavigationController
    ) {
        self.parent = parent
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = RecuitmentManagementVC(coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
    
    public func coordinatorDidFinish() {
        
    }
}

extension RecruitmentManagementCoordinator {
    
    func showCenterRegisterScreen() {
        parent?.centerProfileRegister()
    }
}
