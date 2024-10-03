//
//  CanterLoginFlowCoordinator.swift
//  Idle-iOS
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore
import AuthFeature
import Domain
import Core

class CanterLoginFlowCoordinator: CanterLoginFlowable {
    
    var childCoordinators: [Coordinator] = []
    
    weak var parent: ParentCoordinator?
    var authCoordinator: AuthCoordinatable? {
        parent as? AuthCoordinatable
    }
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit { printIfDebug("deinit \(Self.self)") }
    
    func start() {
        login()
    }
}

extension CanterLoginFlowCoordinator: CanterLoginCoordinatable {
    
    func login() {
        
    }
    
    func setNewPassword() {
        
    
    }
    
    func authFinished() {
        
        authCoordinator?.authFinished()
    }
}
