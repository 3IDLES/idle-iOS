//
//  AuthCoordinator+Extension.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import Foundation
import PresentationCore

extension AuthCoordinator: AuthCoordinatable {
    
    public func auth(type: AuthType) {
        
        switch type {
        case .agent:
            
            let coordinator = AgentAuthCoordinator(navigationController: navigationController)
            
            addChildCoordinator(coordinator)
            
            coordinator.parent = self
            
            coordinator.start()
            
        case .agency:
            return
        }
    }

    public func authFinished() {
        
        clearChildren()
        
        parent?.removeChildCoordinator(self)
    }
}
