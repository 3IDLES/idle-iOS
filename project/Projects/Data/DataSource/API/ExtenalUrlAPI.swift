//
//  ExtenalUrlAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import Moya
import Alamofire

public enum ExtenalUrlAPI {
    
    case uploadImageToS3(url: String, data: Data)
}

extension ExtenalUrlAPI: BaseAPI {
    
    public var apiType: APIType {
        var baseUrl: String!
        switch self {
        case .uploadImageToS3(let url, _):
            baseUrl = url
        }
        return .external(url: baseUrl)
    }
    
    public var path: String {
        switch self {
        default:
            ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .uploadImageToS3:
            .put
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .uploadImageToS3(_, let data):
            .requestData(data)
        }
    }
}
