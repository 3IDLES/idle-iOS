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

public enum KeyValueStoreKey {
    public static let kaccessToken = "idle_accessToken"
    public static let krefreshToken = "idle_refreshToken"
}

public extension KeyValueStore {

    func getAuthToken() -> (accessToken: String, refreshToken: String)? {
        
        guard let accessToken = get(key: KeyValueStoreKey.kaccessToken), let refreshToken = get(key: KeyValueStoreKey.krefreshToken) else {
            return nil
        }
        
        return (accessToken, refreshToken)
    }
    
    func saveAuthToken(accessToken: String, refreshToken: String) throws {
        
        try save(key: KeyValueStoreKey.kaccessToken, value: accessToken)
        try save(key: KeyValueStoreKey.krefreshToken, value: refreshToken)
    }
}
