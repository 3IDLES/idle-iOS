//
//  RemoteConfigService.swift
//  BaseFeature
//
//  Created by choijunios on 10/15/24.
//

import Foundation


import RxSwift

public enum RemoteConfigError: Error, LocalizedError {
    case remoteConfigUnAvailable
    case keyDoesntExist(key: String)
    
    public var errorDescription: String? {
        switch self {
        case .remoteConfigUnAvailable:
            "리모트 컨피그가 유효하지 않음"
        case .keyDoesntExist(let errorKey):
            "리모트 컨피그에 존재하지 않는 키임 키: \(errorKey)"
        }
    }
}

public protocol RemoteConfigService {
    
    func fetchRemoteConfig() -> Single<Result<Bool, Error>>
    
    func getJSONProperty<T: Decodable>(key: String) throws -> T
    
    func getBoolProperty(key: String) throws -> Bool
}
