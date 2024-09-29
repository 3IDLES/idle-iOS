//
//  RegisterCenterInfoCoordinator.swift
//  CenterFeature
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import PresentationCore
import Domain
import Core

public class RegisterCenterInfoCoordinator: ChildCoordinator {
    
    public weak var viewControllerRef: UIViewController?
    public weak var parent: ParentCoordinator?
    var centerProfileRegisterCoordinator: CenterProfileRegisterCoordinatable? {
        parent as? CenterProfileRegisterCoordinatable
    }
    
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        printIfDebug("\(String(describing: RegisterCenterInfoCoordinator.self))")
    }
    
    public func start() {
        let vc = RegisterCenterInfoVC(coordinator: self)
        let vm = RegisterCenterInfoVM(coordinator: self)
        vc.bind(viewModel: vm)
        
        viewControllerRef = vc
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func coordinatorDidFinish() {
        parent?.removeChildCoordinator(self)
        popViewController()
    }
}

extension RegisterCenterInfoCoordinator {
    
    func showPreviewScreen(stateObject: CenterProfileRegisterState) {
        centerProfileRegisterCoordinator?.showPreviewScreen(stateObject: stateObject)
    }
    
    func registerFinished() {
        centerProfileRegisterCoordinator?.registerFinished()
    }
}
