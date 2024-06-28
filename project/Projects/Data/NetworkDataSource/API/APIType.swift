//
//  APIType.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation

enum APIType {
    
    case test
    
    var additionalPath: String {
        
        switch self {
        case .test:
            return "users"
        }
    }
}

enum ReqeustConponents {
    
    enum Header {
        
        case authorization
        case contentType
        
        var key: String {
            
            switch self {
            case .authorization:
                return "Authorization"
            case .contentType:
                return "Content-Type"
            }
        }
        
        var defaultValue: String {
            
            switch self {
            case .authorization:
                return "-"
            case .contentType:
                return "application/json"
            }
        }
    }
    
    enum HTTPMethod {
        
        case get
        case post
        case put
        case delete
        
        var value: String {
            
            switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .delete:
                return "DELETE"
            }
        }
    }
}
