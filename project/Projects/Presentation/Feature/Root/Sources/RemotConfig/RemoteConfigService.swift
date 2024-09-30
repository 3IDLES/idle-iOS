//
//  asd.swift
//  RootFeature
//
//  Created by choijunios on 9/29/24.
//

import Foundation
import FirebaseRemoteConfig
import RxSwift
import Domain

public class RemoteConfigService {
    
    static let shared: RemoteConfigService = .init()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let settings = RemoteConfigSettings()
    
    private init() {
        remoteConfig.configSettings = settings
    }
    
    public func fetchRemoteConfig() -> Single<Result<Bool, Error>> {
        
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
