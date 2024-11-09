//
//  MockLocalStorageService.swift
//  Testing
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import DataSource

class MockLocalStorageService: LocalStorageService {
    
    var source: [String: Any] = [:]
    
    func fetchData<Value>(key: String) -> Value? {
        source[key] as? Value
    }
    
    func saveData<Value>(key: String, value: Value) {
        source[key] = value
    }
    
    func remove(key: String) {
        source.removeValue(forKey: key)
    }
}
