//
//  AuthService.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/8/24.
//

import Foundation

public class AuthService: BaseNetworkService<AuthAPI> {
    
    public init() { }
    
    public override init(keyValueStore: KeyValueStore) {
        super.init(keyValueStore: keyValueStore)
    }
}
