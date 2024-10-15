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
    case users
    case job_postings
    case crawling_job_postings
    case external(url: String)
    case applys
    case notificationToken
    case notifications
}

// MARK: BaseAPI
public protocol BaseAPI: TargetType {
    
    var apiType: APIType { get }
}

public extension BaseAPI {
    
    var baseURL: URL {
        
        var baseStr = NetworkConfig.baseUrl
        
        switch apiType {
        case .auth:
            baseStr += "/auth"
        case .users:
            baseStr += "/users"
        case .job_postings:
            baseStr += "/job-postings"
        case .crawling_job_postings:
            baseStr += "/crawling-job-postings"
        case .applys:
            baseStr += "/applys"
        case .external(let url):
            baseStr = url
        case .notificationToken:
            baseStr += "/fcm"
        case .notifications:
            baseStr += "/notifications"
        }
        
        return URL(string: baseStr)!
    }
    
    /// Default header
    var headers: [String : String]? {
        
        switch apiType {
        default:
            ["Content-Type": "application/json"]
        }
    }
    
    var validationType: ValidationType { .successCodes }
}
