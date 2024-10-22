//
//  MockAssemblies.swift
//  Testing
//
//  Created by choijunios on 10/16/24.
//

import Foundation

import BaseFeature
import DataSource
import Domain


import Swinject

public let MockAssemblies: [Assembly] = [
    MockDataAssembly(),
    MockDomainAssembly(),
    ServiceAssembly()
]

// MARK: Domain Assembly
struct MockDomainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(AuthInputValidationUseCase.self) { _ in
            DefaultAuthInputValidationUseCase()
        }
        
        container.register(AuthUseCase.self) { _ in
            MockAuthUseCase()
        }
    }
}

// MARK: Data Assembly
struct MockDataAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(AuthInputValidationRepository.self) { _ in
            MockAuthInputValidationRepository()
        }
        
        container.register(KeyValueStore.self) { _ in
            TestKeyValueStore()
        }
        
        container.register(LocalStorageService.self) { _ in
            MockLocalStorageService()
        }
        
        container.register(NotificationsRepository.self) { _ in
            MockNotificationsRepository()
        }
    }
}

// MARK: Service Assembly

struct ServiceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(RouterProtocol.self) { _ in
            Router()
        }
        .inObjectScope(.container)
    }
}
