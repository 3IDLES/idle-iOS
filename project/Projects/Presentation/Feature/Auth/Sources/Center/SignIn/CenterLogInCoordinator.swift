//
//  CenterLogInCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/3/24.
//

import Foundation
import Domain
import BaseFeature
import Core

public enum CenterLogInCoordinatorDestination {
    case centerMainPage
}

public class CenterLogInCoordinator: BaseCoordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var startFlow: ((CenterLogInCoordinatorDestination) -> ())!
    
    public init() { }
    
    public override func start() {
        
        let viewModel = CenterLoginViewModel()
        viewModel.presentCenterMainPage = { [weak self] in
            self?.startFlow(.centerMainPage)
        }
        viewModel.presentSetupNewPasswordPage = { [weak self] in
            self?.startSetupNewPasswordFlow()
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        let viewController = CenterLoginViewController(viewModel: viewModel)
        
        router.push(module: viewController, animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
    
    func startSetupNewPasswordFlow() {
        let coordinator = CenterSetupNewPasswordCoordinator()
        addChild(coordinator)
        coordinator.start()
    }
}
