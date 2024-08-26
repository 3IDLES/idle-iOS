//
//  asd.swift
//  DataSource
//
//  Created by choijunios on 8/26/24.
//

import Foundation

public class DefaultLocalStorageService: LocalStorageService {

    let userDefaults: UserDefaults = .init()
    
    public init() { }
    
    public func fetchData<Value>(key: String) -> Value? {
        userDefaults.value(forKey: key) as? Value
    }
    
    public func saveData<Value>(key: String, value: Value) {
        userDefaults.setValue(value, forKey: key)
    }
    
    public func remove(key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
