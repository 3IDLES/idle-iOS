//
//  CenterProfileCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import PresentationCore
import BaseFeature
import Domain

/// 내센터, 다른 센터를 모두 불러올 수 있습니다.
public class CenterProfileCoordinator: Coordinator {
    
    public var onFinish: (() -> ())?
    
    let router: Router
    let mode: ProfileMode
    
    public init(router: Router, mode: ProfileMode) {
        self.router = router
        self.mode = mode
    }
    
    public func start() {
        
        let viewModel = CenterProfileViewModel(mode: mode)
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = CenterProfileViewController()
        viewController.bind(viewModel: viewModel)
            
        router.push(module: viewController, animated: true)
    }
}
