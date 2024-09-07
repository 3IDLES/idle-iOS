//
//  CrawlingPostAPI.swift
//  DataSource
//
//  Created by choijunios on 9/6/24.
//

import Foundation
import Alamofire
import Moya

public enum CrawlingPostAPI {
    
    case getPostList(nextPageId: String?, requestCnt: Int)
    case getDetail(postId: String)
    case getWorknetFavoritePost
}

extension CrawlingPostAPI: BaseAPI {
    public var apiType: APIType {
        .crawling_job_postings
    }
    
    public var path: String {
        switch self {
        case .getPostList:
            ""
        case .getDetail(let postId):
            "/\(postId)"
        case .getWorknetFavoritePost:
            "/my/favorites"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getPostList:
            .get
        case .getDetail:
            .get
        case .getWorknetFavoritePost:
            .get
        }
    }
    
    var bodyParameters: Parameters? {
        var params: Parameters = [:]
        switch self {
        case .getPostList(let nextPageId, let requestCnt):
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
        case .getPostList:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getPostList:
            .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        default:
            .requestPlain
        }
    }
}
