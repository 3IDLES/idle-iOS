//
//  TokenTesting.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import RxSwift
@testable import NetworkDataSource

// TestKeyValueStore
public class TestKeyValueStore: KeyValueStore {
    
    public init(testStore: [String : String] = [:]) {
        self.testStore = [
            Key.Auth.kaccessToken: "access_token",
            Key.Auth.krefreshToken: "refresh_token",
        ].merging(testStore, uniquingKeysWith: { $1 })
    }
    
    var testStore: [String: String] = [:]
    
    public func save(key: String, value: String) throws {
        
        testStore[key] = value
    }
    
    public func get(key: String) -> String? {
        
        return testStore[key]
    }
    
    public func delete(key: String) throws {
        
        testStore.removeValue(forKey: key)
    }
    
    public func removeAll() throws {
        
        testStore.removeAll()
    }
}
