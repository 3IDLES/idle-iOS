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
    
    // Common
    case startPhoneNumberAuth(phoneNumber: String)
    case checkAuthNumber(phoneNumber: String, authNumber: String)
    case reissueToken(refreshToken: String)
    
    // Center
    case centerJoinStatus
    case requestCenterJoin
    case authenticateBusinessNumber(businessNumber: String)
    case checkIdDuplication(id: String)
    case registerCenterAccount(data: Data)
    case centerLogin(id: String, password: String)
    case deregisterCenterAccount(reason: String, password: String)
    case signoutCenterAccount
    
    // Worker
    case registerWorkerAccount(data: Data)
    case workerLogin(phoneNumber: String, verificationNumber: String)
    case signoutWorkerAccount
    case deregisterWorkerAccount(reason: String)
}

extension AuthAPI: BaseAPI {

    public var apiType: APIType { .auth }
    
    public var method: Moya.Method {
        
        switch self {
        case .reissueToken:
            return .post
        case .startPhoneNumberAuth:
            return .post
        case .checkAuthNumber:
            return .post
            
            
        case .centerJoinStatus:
            return .get
        case .requestCenterJoin:
            return .patch
        case .authenticateBusinessNumber:
            return .get
        case .checkIdDuplication:
            return .get
        case .registerCenterAccount:
            return .post
        case .centerLogin:
            return .post
        case .signoutCenterAccount:
            return .post
        case .deregisterCenterAccount:
            return .post
        
            
        case .registerWorkerAccount:
            return .post
        case .workerLogin:
            return .post
        case .signoutWorkerAccount:
            return .post
        case .deregisterWorkerAccount:
            return .post
        }
    }
    
    public var path: String {
        switch self {
        case .startPhoneNumberAuth:
            "common/send"
        case .checkAuthNumber:
            "common/confirm"
        case .reissueToken:
            "common/refresh"
            
            
        case .authenticateBusinessNumber(let businessNumber):
            "center/authentication/\(businessNumber)"
        case .checkIdDuplication(id: let id):
            "center/validation/\(id)"
            
        case .centerJoinStatus:
            "/center/join/status"
        case .requestCenterJoin:
            "/center/join/verify"
        case .registerCenterAccount:
            "center/join"
        case .centerLogin:
            "center/login"
        case .signoutCenterAccount:
            "center/logout"
        case .deregisterCenterAccount:
            "center/withdraw"
            
            
        case .registerWorkerAccount:
            "carer/join"
        case .workerLogin:
            "carer/login"
        case .signoutWorkerAccount:
            "carer/logout"
        case .deregisterWorkerAccount:
            "carer/withdraw"
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
        case .centerLogin(let id, let password):
            params["identifier"] = id
            params["password"] = password
        case .deregisterCenterAccount(let reason, let password):
            params["reason"] = reason
            params["password"] = password
        case .reissueToken(let refreshToken):
            params["refreshToken"] = refreshToken
        case .workerLogin(let phoneNumber, let verificationNumber):
            params["phoneNumber"] = phoneNumber
            params["verificationNumber"] = verificationNumber
        case .deregisterWorkerAccount(let reason):
            params["reason"] = reason
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
    
    public var validationType: ValidationType {
        .successCodes
    }
    
    public var task: Task {
        switch self {
        case .startPhoneNumberAuth:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .checkAuthNumber:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .registerCenterAccount(let data):
            return .requestData(data)
        case .centerLogin:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .deregisterCenterAccount:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .reissueToken:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .registerWorkerAccount(let data):
            return .requestData(data)
        case .workerLogin:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        case .deregisterWorkerAccount:
            return .requestParameters(parameters: bodyParameters ?? [:], encoding: parameterEncoding)
        default:
            return .requestPlain
        }
    }
}
