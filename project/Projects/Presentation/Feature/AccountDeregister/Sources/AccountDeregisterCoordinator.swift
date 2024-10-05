//
//  AccountDeregisterCoordinator.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 10/5/24.
//

import Foundation
import BaseFeature
import Domain

public class AccountDeregisterCoordinator: Coordinator2 {
    
    public var onFinish: (() -> ())?
    
    let router: Router
    let userType: UserType
    
    public init(router: Router, userType: UserType) {
        self.router = router
        self.userType = userType
    }
    
    public func start() {
        
        
    }
}

extension AccountDeregisterCoordinator {
    
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
        
        router.push(module: viewController, animated: true)
    }
    
    func startPhonenumberAuthFlow(_ reasons: [String]) {
        
        
    }
    
    func startPasswordAuthFlow(_ reasons: [String]) {
        
        
    }
}
