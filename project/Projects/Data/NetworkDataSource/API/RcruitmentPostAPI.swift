//
//  RcruitmentPostAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/8/24.
//

import Moya
import Foundation
import Alamofire
import Entity

public enum RcruitmentPostAPI {
    
    // Common
    case postDetail(id: String, userType: UserType)
    
    // Center
    case registerPost(postData: Data)
    case editPost(id: String, postData: Data)
    case removePost(id: String)
    case closePost(id: String)
    
    // Worker
    case postList(nextPageId: String?, requestCnt: Int)
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
        case .postList:
            ""
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
        case .postList:
            .get
        }
    }
    
    var bodyParameters: Parameters? {
        var params: Parameters = [:]
        switch self {
        case .postList(let nextPageId, let requestCnt):
            if let nextPageId {
                params["next"] = nextPageId
            }
            params["limit"] = requestCnt
        default:
            break
        }
        return params
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .postList:
            .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .registerPost(let bodyData):
            .requestData(bodyData)
        case .editPost(_, let editData):
            .requestData(editData)
        default:
            .requestPlain
        }
    }
}
