//
//  NotificationPageCoordinator.swift
//  NotificationPageFeature
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import BaseFeature
import Core


public class NotificationPageCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var onFinish: (() -> ())?
    
    public func start() {
        
        let viewModel = NotificationPageViewModel()
        viewModel.presentAlert = { [weak self] alertObject in
            self?.router.presentDefaultAlertController(object: alertObject)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = NotificationPageVC(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
}
