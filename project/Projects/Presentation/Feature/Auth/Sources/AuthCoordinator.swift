//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation
import BaseFeature
import Core

public enum AuthCoordinatorDestination {
    
    case workerRegisterPage
    case centerRegisterPage
    case loginPage
}

public class AuthCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var onFinish: (() -> ())?
    
    public init() { }
    
    public var startFlow: ((AuthCoordinatorDestination) -> ())!
    
    public func start() {
        
        let viewModel = SelectAuthTypeViewModel()
        
        viewModel.presentLoginPage = { [weak self] in
            self?.startFlow(.loginPage)
        }
        
        viewModel.presentCenterRegisterPage = { [weak self] in
            self?.startFlow(.centerRegisterPage)
        }
        
        viewModel.presentWorkerRegisterPage = { [weak self] in
            self?.startFlow(.workerRegisterPage)
        }
        
        let viewController = SelectAuthTypeViewController()
        viewController.bind(viewModel: viewModel)
        
        router.replaceRootModuleTo(
            module: viewController,
            animated: true
        ) { [weak self] in
            self?.onFinish?()
        }
    }
}
