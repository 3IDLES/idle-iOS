//
//  TestAssembly.swift
//  DataTests
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import DataSource


import Swinject

class TestAssembly: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(KeyValueStore.self) { _ in
            TestKeyValueStore()
        }
    }
}
