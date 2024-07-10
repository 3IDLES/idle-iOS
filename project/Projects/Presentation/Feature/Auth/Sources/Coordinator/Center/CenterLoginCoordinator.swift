//
//  CenterLoginCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

public class CenterLoginCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: (any PresentationCore.DisposableViewController)?

    public var navigationController: UINavigationController
    
    public var parent: CenterAuthCoordinatable?
    
    private var viewModel: CenterLoginViewModel?
    
    public init(
        viewModel: CenterLoginViewModel,
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let viewController = CenterLoginViewController(
            coordinator: self,
            viewModel: self.viewModel!
        )
        
        self.viewModel = nil
        viewControllerRef = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func coordinatorDidFinish() {
        
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}
