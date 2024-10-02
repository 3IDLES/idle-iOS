//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by choijunios on 10/2/24.
//

import Foundation
import BaseFeature

public enum AuthCoordinatorDestination {
    
    case workerRegisterPage
    case centerRegisterPage
    case loginPage
}

public class AuthCoordinator: BaseCoordinator {
    
    let router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
    public var startFlow: ((AuthCoordinatorDestination) -> ())!
    
    public override func start() {
        
        let vm = SelectAuthTypeViewModel()
        
        vm.presentLoginPage = { [weak self] in
            self?.startFlow(.loginPage)
        }
        
        vm.presentCenterRegisterPage = { [weak self] in
            self?.startFlow(.centerRegisterPage)
        }
        
        vm.presentWorkerRegisterPage = { [weak self] in
            self?.startFlow(.workerRegisterPage)
        }
        
        let vc = SelectAuthTypeViewController()
        vc.bind(viewModel: vm)
        
        router.push(
            module: vc, animated: true)
    }
}
