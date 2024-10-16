//
//  WorkerMyProfileCoordinator.swift
//  UserProfileFeature
//
//  Created by choijunios on 10/5/24.
//

import Foundation
import BaseFeature
import Core

public class WorkerMyProfileCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var onFinish: (() -> ())?
    
    public init() { }
        
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
