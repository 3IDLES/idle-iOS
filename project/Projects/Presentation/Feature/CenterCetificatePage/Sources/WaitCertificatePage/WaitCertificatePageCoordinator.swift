//
//  WaitCertificatePageCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 9/11/24.
//

import UIKit
import BaseFeature
import Domain
import Core

public enum WaitCertificatePageCoordinatorDestination {
    case authFlow
    case makeProfileFlow
}

public class WaitCertificatePageCoordinator: Coordinator2 {
    
    public var onFinish: (() -> ())?
    
    public var startFlow: ((WaitCertificatePageCoordinatorDestination) -> ())!
    
    let router: Router

    public init(router: Router) {
        self.router = router
    }
    
    deinit {
        printIfDebug("\(String(describing: WaitCertificatePageCoordinator.self))")
    }
    
    public func start() {
        
        let viewModel = WaitCertificatePageViewModel()
        viewModel.changeToAuthPage = { [weak self] in
            self?.startFlow(.authFlow)
        }
        viewModel.presentMakeProfilePage = { [weak self] in
            self?.startFlow(.makeProfileFlow)
        }
        
        let viewController = WaitCertificatePageViewController()
        
        router.replaceRootModuleTo(module: viewController, animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
}
