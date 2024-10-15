//
//  PresentationAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import BaseFeature
import RootFeature


import Swinject

public struct PresentationAssembly: Assembly {
    public func assemble(container: Container) {
        
        container.register(RemoteConfigService.self) { _ in
            DefaultRemoteConfigService()
        }
        .inObjectScope(.container)
        
        container.register(RouterProtocol.self) { _ in
            Router()
        }
        .inObjectScope(.container)
        
        container.register(RemoteNotificationHelper.self) { _ in
            DefaultRemoteNotificationHelper()
        }
        .inObjectScope(.container)
    }
}
