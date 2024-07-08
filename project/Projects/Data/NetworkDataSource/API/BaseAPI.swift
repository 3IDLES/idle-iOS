//
//  BaseAPI.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import Moya

public enum APIType {
    
    case auth
}

// MARK: BaseAPI
public protocol BaseAPI: TargetType {
    
    var apiType: APIType { get }
}

public extension BaseAPI {
    
    var baseURL: URL {
        
        var baseStr = NetworkConfig.baseUrl
        
        let apiVersion = "v1"
        
        baseStr += "/api/\(apiVersion)"
        
        switch apiType {
        case .auth:
            baseStr += "/auth"
        }
        
        return URL(string: baseStr)!
    }
    
    /// Default header
    var headers: [String : String]? {
        
        return ["Content-Type": "application/json"]
    }
}
