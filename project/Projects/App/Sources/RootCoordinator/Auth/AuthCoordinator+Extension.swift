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
        case .worker:
            
            let coordinator = WorkerAuthCoordinator(
                dependency: .init(
                    navigationController: navigationController,
                    injector: injector
                )
            )
            
            addChildCoordinator(coordinator)
            
            coordinator.parent = self
            
            coordinator.start()
            
        case .center:
            
            let coordinator = CenterAuthCoorinator(
                dependency: .init(
                    navigationController: navigationController,
                    injector: injector
                )
            )
            
            addChildCoordinator(coordinator)
            
            coordinator.parent = self
            
            coordinator.start()
            return
        }
    }

    public func authFinished() {
        
        clearChildren()
        
        parent?.removeChildCoordinator(self)
    }
}
