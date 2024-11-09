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
import Logger


import Swinject

public struct LoggerAssembly: Assembly {
    public func assemble(container: Container) {
        
        container.register(Logger.self) { _ in
            #if DEBUG
                return MockLogger()
            #endif
            
            return AmplitudeLogger()
        }
        .inObjectScope(.container)
    }
}
