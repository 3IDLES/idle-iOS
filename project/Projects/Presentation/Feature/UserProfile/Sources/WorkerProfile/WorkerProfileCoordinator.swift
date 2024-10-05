//
//  WorkerProfileCoordinator.swift
//  WorkerFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import BaseFeature
import Domain
import Core

public class WorkerProfileCoordinator: Coordinator2 {
    
    public var onFinish: (() -> ())?
    let router: Router
    let id: String
    
    public init(router: Router, id: String) {
        self.router = router
        self.id = id
    }
    
    deinit {
        printIfDebug("\(String(describing: WorkerProfileCoordinator.self))")
    }
    
    public func start() {

        let viewModel = WorkerProfileViewModel(id: id)
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = WorkerProfileViewController()
        viewController.bind(viewModel)
        
        router.push(module: viewController, animated: true)
    }
}
