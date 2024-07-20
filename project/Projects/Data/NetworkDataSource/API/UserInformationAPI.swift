//
//  UserInformationAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import Moya
import Alamofire

public enum UserInformationAPI {
    
    enum UserType {
        case center, worker
    }
    
    // 프로필 조회
    case getCenterProfile
//    case getPreSignedUrlForProfile(type: UserType)
//    case callbackForUpdateProfileImage(type: UserType)
}

extension UserInformationAPI: BaseAPI {
    
    public var apiType: APIType {
        .users
    }
    
    public var path: String {
        switch self {
        case .getCenterProfile:
            "/center/my/profile"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getCenterProfile:
            .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getCenterProfile:
            return .requestPlain
        }
    }
    
}
