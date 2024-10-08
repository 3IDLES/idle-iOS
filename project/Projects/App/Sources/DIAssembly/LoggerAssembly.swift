//
//  LoggerAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 9/18/24.
//

import Foundation
import RootFeature
import AuthFeature
import PresentationCore
import CenterMainPageFeature

import Swinject

public struct LoggerAssembly: Assembly {
    public func assemble(container: Container) {
        
        // MARK: Message pusher
        container.register(LoggerMessagePublisher.self) { _ in
            #if DEBUG || QA
            return DebugLogger()
            #endif
            return AmplitudeLogger()
        }
        
        // MARK: Overall logger
        container.register(OverallLogger.self) { resolver in
            let messagePublisher = resolver.resolve(LoggerMessagePublisher.self)!
            return DefaultOverallLogger(publisher: messagePublisher)
        }
        .inObjectScope(.container)
        
        container.register(CenterRegisterLogger.self) { resolver in
            let overallLogger = resolver.resolve(OverallLogger.self)!
            return overallLogger
        }
        
        container.register(WorkerRegisterLogger.self) { resolver in
            let overallLogger = resolver.resolve(OverallLogger.self)!
            return overallLogger
        }
        
        container.register(PostRegisterLogger.self) { resolver in
            let overallLogger = resolver.resolve(OverallLogger.self)!
            return overallLogger
        }
    }
}
