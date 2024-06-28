//
//  KeyChainList.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import KeychainAccess

class KeyChainList {
    
    private init() { }
    
    static let shared = KeyChainList()
    
    private let keyChain = Keychain(service: "com.service.idle")
}

extension KeyChainList: KeyValueStore {
    
    func save(key: String, value: String) throws {
        try keyChain.set(value, key: key)
    }
    
    func delete(key: String) throws {
        try keyChain.remove(key)
    }
    
    func removeAll() throws {
        try keyChain.removeAll()
    }
    
    func get(key: String) -> String? {
        try? keyChain.get(key)
    }
}
