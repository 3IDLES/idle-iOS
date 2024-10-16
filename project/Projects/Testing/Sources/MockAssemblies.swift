//
//  MockAssemblies.swift
//  Testing
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import Domain
import DataSource


import Swinject

let MockAssemblies: [Assembly] = [
    MockDataAssembly(),
    MockDomainAssembly(),
]

// MARK: Domain Assembly
struct MockDomainAssembly: Assembly {
    
    func assemble(container: Container) {
        
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
    }
}
