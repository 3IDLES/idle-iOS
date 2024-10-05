//
//  WorkerMyProfileCoordinator.swift
//  UserProfileFeature
//
//  Created by choijunios on 10/5/24.
//

import Foundation
import BaseFeature

public class WorkerMyProfileCoordinator: Coordinator2 {
    
    public var onFinish: (() -> ())?
    let router: Router
    
    public init(router: Router) {
        self.router = router
    }
        
    public func start() {
        
        let viewModel = WorkerMyProfileViewModel()
        viewModel.presentDefaultAlert = { [weak self] object in
            self?.router.presentDefaultAlertController(object: object)
        }
        viewModel.presentEditPage = { [weak self] viewModel in
            self?.presentEditPage(viewModel: viewModel)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = WorkerProfileViewController()
        viewController.bind(viewModel)
        
        router.push(module: viewController, animated: true)
    }
}

private extension WorkerMyProfileCoordinator {
    
    func presentEditPage(viewModel: WorkerProfileEditViewModelable) {
        let viewController = EditWorkerProfileViewController()
        viewController.bind(viewModel: viewModel)
        router.push(module: viewController, animated: true)
    }
}
