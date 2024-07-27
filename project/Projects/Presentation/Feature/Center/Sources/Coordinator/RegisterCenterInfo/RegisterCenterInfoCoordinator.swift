//
//  RegisterCenterInfoCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import PresentationCore

public class RegisterCenterInfoCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: CenterProfileRegisterCoordinatable?
    
    public let navigationController: UINavigationController
    
    public let viewModel: RegisterCenterInfoViewModelable
    
    public init(
        viewModel: RegisterCenterInfoViewModelable,
        navigationController: UINavigationController
    ) {
        self.viewModel = viewModel
        self.navigationController = navigationController
    }
    
    public func start() {
        let vc = RegisterCenterInfoVC()
        vc.bind(viewModel: viewModel)
        vc.coordinator = self.parent
        
        viewControllerRef = vc
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
    }
    
}
