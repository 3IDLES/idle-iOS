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
import Core

/// 내센터, 다른 센터를 모두 불러올 수 있습니다.
public class CenterProfileCoordinator: Coordinator {
    
    // Injected
    @Injected var router: RouterProtocol
    
    public var onFinish: (() -> ())?
    
    let mode: ProfileMode
    
    public init(mode: ProfileMode) {
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
