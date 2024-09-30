//
//  CenterLoginCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import Domain
import PresentationCore
import Core

public class CenterLoginCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?

    public var navigationController: UINavigationController
    
    public weak var parent: ParentCoordinator?
    var canterLoginFlowaCoordinator: CanterLoginFlowable? {
        parent as? CanterLoginFlowable
    }
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    public func start() {
        
        let vm = CenterLoginViewModel(coordinator: self)
        let vc = CenterLoginViewController(viewModel: vm)
        
        viewControllerRef = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        popViewController()
        parent?.removeChildCoordinator(self)
    }
}

extension CenterLoginCoordinator {
    
    func showSetNewPasswordScreen() {
        canterLoginFlowaCoordinator?.setNewPassword()
    }
    
    /// Auth가 종료된 경우
    func authFinished() {
        canterLoginFlowaCoordinator?.authFinished()
    }
}
