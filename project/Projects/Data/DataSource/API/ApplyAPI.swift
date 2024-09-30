//
//  ApplyAPI.swift
//  DataSource
//
//  Created by choijunios on 9/3/24.
//

import Foundation
import Domain


import Moya
import Alamofire

public enum ApplyAPI {
    case applys(jobPostingId: String, applyMethodType: String)
}

extension ApplyAPI: BaseAPI {
    
    public var apiType: APIType {
        .applys
    }
    
    public var path: String {
        switch self {
        case .applys:
            ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .applys:
            .post
        }
    }
    
    var bodyParameters: Parameters? {
        var params: Parameters = [:]
        switch self {
        case .applys(let jobPostingId, let applyMethodType):
            params["jobPostingId"] = jobPostingId
            params["applyMethodType"] = applyMethodType
            return params
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .applys:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        }
    }
}
