//
//  PresentationAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 10/15/24.
//

import Foundation

import ChattingFeatureInterface
import ChattingFeature
import BaseFeature
import RootFeature


import Swinject

public struct PresentationAssembly: Assembly {
    public func assemble(container: Container) {
        
        // MARK: Remote config
        container.register(RemoteConfigService.self) { _ in
            DefaultRemoteConfigService()
        }
        .inObjectScope(.container)
        
        // MARK: Router
        container.register(RouterProtocol.self) { _ in
            Router()
        }
        .inObjectScope(.container)
        
        // MARK: Remote notification
        container.register(RemoteNotificationHelper.self) { _ in
            DefaultRemoteNotificationHelper()
        }
        .inObjectScope(.container)
        
        // MARK: Chatting feature
        container.register(ChattingListFeatureFactory.self) { _ in
            DefaultChattingListFeatureFactory()
        }
    }
}
