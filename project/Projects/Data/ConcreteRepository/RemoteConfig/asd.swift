//
//  asd.swift
//  ConcreteRepository
//
//  Created by choijunios on 9/13/24.
//

import Foundation
import RepositoryInterface

import RxSwift
import FirebaseRemoteConfig
import Entity

public class DefaultRemoteConfigRepository: RemoteConfigRepository {
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let settings = RemoteConfigSettings()
    
    public init() {
        remoteConfig.configSettings = settings
    }
    
    public func fetchRemoteConfig() -> RxSwift.Single<Result<Bool, Error>> {
        
        Single.create { [weak self] single in
            
            self?.remoteConfig.fetch { status, error in
                
                if status == .success {
                    self?.remoteConfig.activate()
                    single(.success(.success(true)))
                } else {
                    single(.success(.success(false)))
                }
            }
            
            return Disposables.create { }
        }
    }
    
    public func getForceUpdateInfo() -> ForceUpdateInfo? {
        let jsonData = remoteConfig["forceUpdate_iOS"].jsonValue
        
        if let jsonData {
            
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonData)
                let decoded = try JSONDecoder().decode(ForceUpdateInfo.self, from: data)
                return decoded
            } catch {
                
                return nil
            }
        }
        return nil
    }
}
