//
//  RcruitmentPostAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/8/24.
//

import Moya
import Foundation

public enum RcruitmentPostAPI {
    
    // Center
    case registerPost(postData: Data)
}

extension RcruitmentPostAPI: BaseAPI {
    
    public var apiType: APIType {
        .job_postings
    }
    
    public var path: String {
        switch self {
        case .registerPost:
            ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .registerPost:
            .post
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
        case .registerPost(let bodyData):
            .requestData(bodyData)
        }
    }
}
