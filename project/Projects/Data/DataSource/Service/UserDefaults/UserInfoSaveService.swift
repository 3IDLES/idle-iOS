//
//  asd.swift
//  DataSource
//
//  Created by choijunios on 8/26/24.
//

import Foundation

/// UserDefaults에 저장가능한 키값을 나타냅니다.
public enum UserInfoStorageKey: String, Hashable {
    // UserType
    case userType = "userType"
    
    // Worker
    case currentWorker = "currentWorker"
    
    // Center
    case currentCenter = "currentCenter"
}

public class DefaultLocalStorageService: LocalStorageService {
    
    public typealias T = UserInfoStorageKey
    
    let userDefaults: UserDefaults = .init()
    
    private init() { }
    
    /// UserDefaults로 부터 데이터를 가져옵니다.
    public func fetchData<Value>(key: T) -> Value? {
        userDefaults.value(forKey: key.rawValue) as? Value
    }
    
    /// UserDefaults에 데이터를 저장합니다.
    public func saveData<Value>(key: T, value: Value) {
        userDefaults.setValue(value, forKey: key.rawValue)
    }
}
