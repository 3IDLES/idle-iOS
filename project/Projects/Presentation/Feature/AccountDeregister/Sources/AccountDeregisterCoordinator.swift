//
//  AccountDeregisterCoordinator.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 10/5/24.
//

import UIKit
import BaseFeature
import Domain

public enum AccountDeregisterCoordinatorDestination {
    case accountAuthFlow
}

public class AccountDeregisterCoordinator: Coordinator2 {
    
    public var onFinish: (() -> ())?
    
    public var startFlow: ((AccountDeregisterCoordinatorDestination) -> ())!
    
    private weak var belowModule: UIViewController?
    
    let router: Router
    let userType: UserType
    
    public init(router: Router, userType: UserType) {
        self.router = router
        self.userType = userType
    }
    
    public func start() {
        switch userType {
        case .center:
            startCenterFlow()
        case .worker:
            startWorkerFlow()
        }
    }
}

public extension AccountDeregisterCoordinator {
    
    func startWorkerFlow() {
        
        let viewModel = WorkerDeregisterReasonsVM()
        viewModel.presentPhonenumberAuthPage = { [weak self] reasons in
            self?.startPhonenumberAuthFlow(reasons)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = DeregisterReasonVC()
        viewController.bind(viewModel: viewModel)
        
        belowModule = router.topViewController
        router.push(module: viewController, animated: true)
    }
    
    func startCenterFlow() {
        
        let viewModel = CenterDeregisterReasonsVM()
        viewModel.presentPasswordAuthPage = { [weak self] reasons in
            self?.startPasswordAuthFlow(reasons)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = DeregisterReasonVC()
        viewController.bind(viewModel: viewModel)
        
        belowModule = router.topViewController
        router.push(module: viewController, animated: true)
    }
    
    func startPhonenumberAuthFlow(_ reasons: [String]) {
        
        let viewModel = PasswordForDeregisterVM(reasons: reasons)
        viewModel.backToPrevModule = { [weak self] in
            if let module = self?.belowModule {
                self?.router.popTo(module: module, animated: true)
            }
        }
        viewModel.changeToAuthFlow = { [weak self] in
            self?.startFlow(.accountAuthFlow)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = PasswordForDeregisterVC()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
    
    func startPasswordAuthFlow(_ reasons: [String]) {
        
        let viewModel = PhoneNumberValidationForDeregisterVM(reasons: reasons)
        viewModel.backToPrevModule = { [weak self] in
            if let module = self?.belowModule {
                self?.router.popTo(module: module, animated: true)
            }
        }
        viewModel.changeToAuthFlow = { [weak self] in
            self?.startFlow(.accountAuthFlow)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = PhoneNumberValidationForDeregisterVC()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
}
