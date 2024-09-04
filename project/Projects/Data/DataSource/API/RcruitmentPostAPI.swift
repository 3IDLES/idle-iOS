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
    
    /// 요양보호사용 센터용 선택가능
    case postDetail(id: String, userType: UserType)
    
    // Center
    // - 공고 CRUD
    case registerPost(postData: Data)
    case editPost(id: String, postData: Data)
    case removePost(id: String)
    case closePost(id: String)
    // - 공고 상세조회
    case getOnGoingPosts
    case getClosedPosts
    case getApplicantList(id: String)
    
    // - 공고 지원자 관련
    case getPostApplicantCount(id: String)
    
    // Worker
    case getOnGoingNativePostListForWorker(nextPageId: String?, requestCnt: String)
    case getFavoritePostListForWorker(nextPageId: String?, requestCnt: String)
    case getAppliedPostListForWorker(nextPageId: String?, requestCnt: String)
    case addFavoritePost(id: String, jobPostingType: RecruitmentPostType)
    case removeFavoritePost(id: String)
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
            
            
        case .getOnGoingPosts:
            "/status/in-progress"
        case .getClosedPosts:
            "/status/completed"
        case .getApplicantList(let id):
            "/\(id)/applicants"
        
            
        case .getPostApplicantCount(let id):
            "/\(id)/applicant-count"
            
            
        case .getOnGoingNativePostListForWorker:
            ""
        case .getFavoritePostListForWorker:
            "/my/favorites"
        case .getAppliedPostListForWorker:
            "/carer/my/applied"
            
        case .addFavoritePost(id: let id):
            "\(id)/favorites"
        case .removeFavoritePost(id: let id):
            "\(id)/favorites"
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
            
            
        case .getOnGoingPosts:
            .get
        case .getClosedPosts:
            .get
        case .getApplicantList:
            .get
            
            
        case .getPostApplicantCount:
            .get
            
            
        case .getOnGoingNativePostListForWorker:
            .get
        case .getFavoritePostListForWorker:
            .get
        case .getAppliedPostListForWorker:
            .get
            
        case .addFavoritePost:
            .post
        case .removeFavoritePost:
            .delete
        }
    }
    
    var bodyParameters: Parameters? {
        var params: Parameters = [:]
        switch self {
        case .getOnGoingNativePostListForWorker(let nextPageId, let requestCnt):
            if let nextPageId {
                params["next"] = nextPageId
            }
            params["limit"] = requestCnt
        case .getFavoritePostListForWorker(let nextPageId, let requestCnt):
            if let nextPageId {
                params["next"] = nextPageId
            }
            params["limit"] = requestCnt
        case .getAppliedPostListForWorker(let nextPageId, let requestCnt):
            if let nextPageId {
                params["next"] = nextPageId
            }
            params["limit"] = requestCnt
        case .addFavoritePost(_, let jobPostingType):
            params["jobPostingType"] = jobPostingType.upscaleEngWord
        default:
            break
        }
        return params
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getOnGoingNativePostListForWorker,
                .getFavoritePostListForWorker,
                .getAppliedPostListForWorker:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getOnGoingNativePostListForWorker,
                .getFavoritePostListForWorker,
                .getAppliedPostListForWorker:
            .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .registerPost(let bodyData):
            .requestData(bodyData)
        case .editPost(_, let editData):
            .requestData(editData)
        case .addFavoritePost:
            .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        default:
            .requestPlain
        }
    }
}
