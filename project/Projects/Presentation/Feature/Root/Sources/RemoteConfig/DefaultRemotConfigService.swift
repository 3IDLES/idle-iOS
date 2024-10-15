//
//  DefaultRemotConfigService.swift
//  RootFeature
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import BaseFeature
import Domain


import FirebaseRemoteConfig
import RxSwift


public class DefaultRemoteConfigService: RemoteConfigService {
    
    // Fetch된 이후 캐싱된다.
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    public init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    public func fetchRemoteConfig() -> Single<Result<Bool, Error>> {
        
        Single.create { [weak self] single in
            
            self?.remoteConfig.fetchAndActivate { status, error in
                single(.success(.success(status != .error)))
            }
            
            return Disposables.create { }
        }
    }
    
    public func getJSONProperty<T: Decodable>(key: String) throws -> T {
        
        guard let jsonData = remoteConfig[key].jsonValue else {
            throw RemoteConfigError.keyDoesntExist(key: key)
        }
        
        let data = try JSONSerialization.data(withJSONObject: jsonData)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        
        return decoded
    }
    
    public func getBoolProperty(key: String) throws -> Bool {
        
        return remoteConfig[key].boolValue
    }
}
