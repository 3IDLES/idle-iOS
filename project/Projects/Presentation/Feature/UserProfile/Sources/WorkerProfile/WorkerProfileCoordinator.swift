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

public class WorkerProfileCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var onFinish: (() -> ())?
    let id: String
    
    public init(id: String) {
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
