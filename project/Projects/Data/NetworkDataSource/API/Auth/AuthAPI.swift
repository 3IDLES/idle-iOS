//
//  AuthAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import Moya
import Alamofire

public enum AuthAPI {
    
    // Core
    case startPhoneNumberAuth(phoneNumber: String)
    case checkAuthNumber(phoneNumber: String, authNumber: String)
    
    // Center
    case authenticateBusinessNumber(businessNumber: String)
}

extension AuthAPI: BaseAPI {

    public var apiType: APIType { .auth}
    
    public var method: Moya.Method {
        
        switch self {
        case .startPhoneNumberAuth:
            return .post
        case .checkAuthNumber:
            return .post
        case .authenticateBusinessNumber:
            return .get
        }
    }
    
    public var path: String {
        switch self {
        case .startPhoneNumberAuth:
            "core/send"
        case .checkAuthNumber:
            "core/confirm"
        case .authenticateBusinessNumber(let businessNumber):
            "center/authentication/\(businessNumber)"
        }
    }
    
    var bodyParameters: Parameters? {
        var params: Parameters = [:]
        switch self {
        case .startPhoneNumberAuth(let phoneNumber):
            params["phoneNumber"] = phoneNumber
        case .checkAuthNumber(let phoneNumber, let authNumber):
            params["phoneNumber"] = phoneNumber
            params["verificationNumber"] = authNumber
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
    
    public var task: Task {
        switch self {
        case .startPhoneNumberAuth:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .checkAuthNumber:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        default:
            return .requestPlain
        }
    }
}
