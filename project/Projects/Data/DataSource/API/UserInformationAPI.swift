//
//  UserInformationAPI.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import Domain


import Moya
import Alamofire

extension UserType {
    var pathUri: String {
        switch self {
        case .center:
            "center"
        case .worker:
            "carer"
        }
    }
}

public enum UserInformationAPI {
    
    // 프로필 생성
    case registerCenterProfile(data: Data)
    
    // 프로필 조회
    // - Center
    case getMyCenterProfile
    case getCenterProfile(id: String)
    case updateCenterProfile(officeNumber: String, introduce: String?)
    
    // - Worker
    case getMyWorkerProfile
    case getOtherWorkerProfile(id: String)
    case updateWorkerProfile(data: Data)
    
    // 프로필 사진 업로드
    case getPreSignedUrl(userType: UserType, imageExt: String)
    case imageUploadSuccessCallback(userType: UserType, imageId: String, imageExt: String)
    
//    case getPreSignedUrlForProfile(type: UserType)
//    case callbackForUpdateProfileImage(type: UserType)
}

extension UserInformationAPI: BaseAPI {
    
    public var apiType: APIType {
        .users
    }
    
    public var path: String {
        switch self {
        case .registerCenterProfile:
            "center/my/profile"
        case .getMyCenterProfile:
            "center/my/profile"
        case .getCenterProfile(let id):
            "center/profile/\(id)"
        case .getMyWorkerProfile:
            "carer/my/profile"
        case .getOtherWorkerProfile(let id):
            "carer/profile/\(id)"
        case .updateWorkerProfile:
            "carer/my/profile"
        case .updateCenterProfile:
            "center/my/profile"
        case .getPreSignedUrl(let type, _):
            "\(type.pathUri)/my/profile-image/upload-url"
        case .imageUploadSuccessCallback(let type, _, _):
            "\(type.pathUri)/my/profile-image/upload-callback"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .registerCenterProfile:
            .post
        case .getMyCenterProfile:
            .get
        case .getCenterProfile:
            .get
        case .updateCenterProfile:
            .patch
        case .getPreSignedUrl:
            .get
        case .imageUploadSuccessCallback:
            .post
        case .getMyWorkerProfile:
            .get
        case .getOtherWorkerProfile:
            .get
        case .updateWorkerProfile:
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
        case .registerCenterProfile(let data):
            return .requestData(data)
        case .updateCenterProfile(let officeNumber, let introduce):
            var bodyData: [String: String] = ["officeNumber": officeNumber]
            if let introduce {
                bodyData["introduce"] = introduce
            }
            return .requestParameters(parameters: bodyData, encoding: parameterEncoding)
        case .getPreSignedUrl(_, let imageExt):
            let params: [String: String] = [
                "imageFileExtension": imageExt
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case.imageUploadSuccessCallback(_, let imageId, let imageExt):
            let params: [String: String] = [
                "imageId": imageId,
                "imageFileExtension": imageExt
            ]
            return .requestParameters(parameters: params, encoding: parameterEncoding)
        case .updateWorkerProfile(let data):
            return .requestData(data)
        default:
            return .requestPlain
        }
    }
}
