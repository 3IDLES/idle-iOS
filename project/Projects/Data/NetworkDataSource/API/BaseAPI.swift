//
//  BaseAPI.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation

protocol BaseAPI {
    
    static var apiType: APIType { get }
    var headers: [String: String] { get }
    var method: ReqeustConponents.HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var endPoint: String { get }
}

extension BaseAPI {
    
    var baseUrl: URL {
        
        var baseUrlString = Config.baseUrlString
        
        [
            Self.apiType.additionalPath,
            endPoint
        ].forEach { path in
            if !path.isEmpty {
                baseUrlString.append("/\(path)")
            }
        }
        
        return URL(string: baseUrlString)!
    }
    
    
    var headers: [String: String] {
        
        return defaultHeaders
    }
    
    var defaultHeaders: [String: String] {
        
        return [
            ReqeustConponents.Header.contentType.key: ReqeustConponents.Header.contentType.defaultValue
        ]
    }
    
    var queryItems: [URLQueryItem]? {
        
        return nil
    }
}
