//
//  BaseAPI.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import Moya

enum APIType {
    
    case test
}

// MARK: BaseAPI
protocol BaseAPI: TargetType {
    
    var apiType: APIType { get }
}

extension BaseAPI {
    
    var baseURL: URL {
        
        let base = URL(string: NetworkConfig.baseUrl)!
        
        return base.appendingPathComponent(self.path)
    }
    
    var path: String {
        
        switch apiType {
        case .test:
            "test"
        default:
            preconditionFailure("APIType is not defined")
        }
    }
    
    /// Default header
    var headers: [String : String]? {
        
        return ["Content-Type": "application/json"]
    }
}
