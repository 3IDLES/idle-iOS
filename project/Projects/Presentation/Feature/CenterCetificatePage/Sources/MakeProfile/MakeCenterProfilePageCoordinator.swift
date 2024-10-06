//
//  RegisterCenterInfoCoordinator.swift
//  WaitCertificatePageCoordinator
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import BaseFeature
import Domain
import Core

public enum MakeCenterProfilePageCoordinatorDestination {
    case centerMainPageFlow
    case authFlow
}

public class MakeCenterProfilePageCoordinator: Coordinator {
    
    public var onFinish: (() -> ())?
    
    public var startFlow: ((MakeCenterProfilePageCoordinatorDestination) -> ())!
    
    let router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
    deinit {
        printIfDebug("\(String(describing: MakeCenterProfilePageCoordinator.self))")
    }
    
    public func start() {
        
        let viewModel = MakeCenterProfileViewModel()
        viewModel.presentOverviewPage = { [weak self] object in
            self?.presentOverviewScreen(stateObject: object)
        }
        viewModel.changeToAuthFlow = { [weak self] in
            self?.startFlow(.authFlow)
        }
        
        let viewController = MakeCenterProfileViewController(viewModel: viewModel)
        
        router.replaceRootModuleTo(module: viewController, animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
    
    func presentOverviewScreen(stateObject: CenterProfileRegisterState) {
        
        let viewModel = MakeCenterProfileOverviewViewModel(stateObject: stateObject)
        viewModel.presentCompleteScreen = { [weak self] object in
            self?.router.presentAnonymousCompletePage(object)
        }
        viewModel.presentCenterMainPage = { [weak self] in
            self?.startFlow(.centerMainPageFlow)
        }
        viewModel.exitPage = { [weak self] in
            self?.router.popModule(animated: true)
        }
        
        let viewController = MakeCenterProfileOverviewViewController()
        viewController.bind(viewModel: viewModel)
        
        router.push(module: viewController, animated: true)
    }
}

