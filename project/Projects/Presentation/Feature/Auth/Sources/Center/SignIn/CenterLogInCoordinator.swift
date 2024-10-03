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
    
    public var startFlow: ((CenterLogInCoordinatorDestination) -> ())!
    
    let router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
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
        
        router.push(module: viewController, animated: true)
    }
    
    func startSetupNewPasswordFlow() {
        let coordinator = CenterSetupNewPasswordCoordinator(router: router)
        addChild(coordinator)
        coordinator.start()
    }
}
