//
//  RcruitmentPostAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/8/24.
//

import Moya
import Foundation
import Entity

public enum RcruitmentPostAPI {
    
    // Common
    case postDetail(id: String, userType: UserType)
    
    // Center
    case registerPost(postData: Data)
    case editPost(id: String, postData: Data)
    case removePost(id: String)
    case closePost(id: String)
}

extension RcruitmentPostAPI: BaseAPI {
    
    public var apiType: APIType {
        .job_postings
    }
    
    public var path: String {
        switch self {
        case .postDetail(let id, let userType):
            "/\(id)/\(userType.pathUri)"
        case .registerPost:
            ""
        case .editPost(let id, _):
            "/\(id)"
        case .removePost(let id):
            "/\(id)"
        case .closePost(let id):
            "/\(id)/end"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .postDetail:
            .get
        case .registerPost:
            .post
        case .editPost:
            .patch
        case .removePost:
            .delete
        case .closePost:
            .patch
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
        case .editPost(_, let editData):
            .requestData(editData)
        default:
            .requestPlain
        }
    }
}
