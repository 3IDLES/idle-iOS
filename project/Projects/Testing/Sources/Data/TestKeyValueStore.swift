//
//  TestKeyValueStore.swift
//  Testing
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import DataSource

class TestKeyValueStore: KeyValueStore {
    
    init(testStore: [String : String] = [:]) {
        self.testStore = [
            Key.Auth.kaccessToken: "access_token",
            Key.Auth.krefreshToken: "refresh_token",
        ].merging(testStore, uniquingKeysWith: { $1 })
    }
    
    var testStore: [String: String] = [:]
    
    func save(key: String, value: String) throws {
        
        testStore[key] = value
    }
    
    func get(key: String) -> String? {
        
        return testStore[key]
    }
    
    func delete(key: String) throws {
        
        testStore.removeValue(forKey: key)
    }
    
    func removeAll() throws {
        
        testStore.removeAll()
    }
}
