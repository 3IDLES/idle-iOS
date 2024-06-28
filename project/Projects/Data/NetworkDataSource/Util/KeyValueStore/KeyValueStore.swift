//
//  KeyValueStore.swift
//  NetworkDataSource
//
//  Created by choijunios on 6/28/24.
//

import Foundation

public protocol KeyValueStore {
    func save(key: String, value: String) throws
    func get(key: String) -> String?
    func delete(key: String) throws
    func removeAll() throws
}

enum Key {
    enum Auth {
        static let kaccessToken = "idle_accessToken"
        static let krefreshToken = "idle_refreshToken"
    }
}

public extension KeyValueStore {

    func getAuthToken() -> (accessToken: String, refreshToken: String)? {
        
        guard let accessToken = get(key: Key.Auth.kaccessToken), let refreshToken = get(key: Key.Auth.krefreshToken) else {
            return nil
        }
        
        return (accessToken, refreshToken)
    }
    
    func saveAuthToken(accessToken: String, refreshToken: String) throws {
        
        try save(key: Key.Auth.kaccessToken, value: accessToken)
        try save(key: Key.Auth.krefreshToken, value: refreshToken)
    }
}
