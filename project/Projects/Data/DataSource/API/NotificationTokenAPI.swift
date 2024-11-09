//
//  NotificationTokenAPI.swift
//  DataSource
//
//  Created by choijunios on 10/8/24.
//

import Foundation
import Moya

public enum NotificationTokenAPI {
    case saveToken(deviceToken: String, userType: String)
    case deleteToken(deviceToken: String)
}

extension NotificationTokenAPI: BaseAPI {
    
    public var apiType: APIType {
        .notificationToken
    }
    
    public var path: String {
        switch self {
        case .saveToken(let deviceToken, let userType):
            "token"
        case .deleteToken(let deviceToken):
            "token"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .saveToken:
            .post
        case .deleteToken:
            .delete
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
        case .saveToken(let deviceToken, let userType):
            var bodyData: [String: String] = [
                "deviceToken": deviceToken,
                "userType": userType
            ]
            return .requestParameters(parameters: bodyData, encoding: parameterEncoding)
        case .deleteToken(let deviceToken):
            var bodyData: [String: String] = [
                "deviceToken": deviceToken
            ]
            return .requestParameters(parameters: bodyData, encoding: parameterEncoding)
        }
    }
}
