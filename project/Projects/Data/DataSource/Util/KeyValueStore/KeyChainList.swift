//
//  KeyChainList.swift
//  DataSource
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import KeychainAccess

public class KeyChainList: KeyValueStore {
    
    public init() { }
    
    private let keyChain = Keychain(service: "com.service.idle")
    
    public func save(key: String, value: String) throws {
        do {
            try keyChain.set(value, key: key)
            #if DEBUG
            print("KeyChain Save Success: \(key)")
            #endif
        } catch {
            #if DEBUG
            print("UserDefaults Save Success: \(key)")
            #endif
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
    
    public func delete(key: String) throws {
        try keyChain.remove(key)
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public func removeAll() throws {
        try keyChain.removeAll()
        
        // UserDefaults의 경우 수동으로 정보를 삭제합니다.
        UserDefaults.standard.removeObject(forKey: KeyValueStoreKey.kaccessToken)
        UserDefaults.standard.removeObject(forKey: KeyValueStoreKey.krefreshToken)
    }
    
    public func get(key: String) -> String? {
        if let value = try? keyChain.get(key) {
            return value
        } else if let value = UserDefaults.standard.string(forKey: key) {
            return value
        }
        return nil
    }
}
