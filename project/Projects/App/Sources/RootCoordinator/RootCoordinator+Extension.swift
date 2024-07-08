//
//  RootCoordinator+Extension.swift
//  Idle-iOS
//
//  Created by choijunios on 6/30/24.
//

import Foundation
import AuthFeature

extension RootCoordinator {
    
    func auth() {
        
        let authCoordinator = AuthCoordinator(
            dependency: .init(
                navigationController: navigationController,
                injector: injector
            )
        )
        
        authCoordinator.start()
    }
}
