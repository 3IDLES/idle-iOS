//
//  AuthError.swift
//  Entity
//
//  Created by choijunios on 7/10/24.
//

import Foundation

public enum AuthError: String, DomainError {
    
    // SECURITY
    case unAuthorizedRequest = "SECURITY-001"
    case invalidLoginRequest = "SECURITY-002"
    case invalidPassword = "SECURITY-003"
    case unregisteredUser = "SECURITY-004"
    
    case accountAlreadyExist="CENTER-002"
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        case .unAuthorizedRequest:
            return "권한이 없습니다."
        case .invalidLoginRequest:
            return "아이디 혹은 비밀번호가 잘못됬습니다."
        case .invalidPassword:
            return "비밀번호가 틀렸습니다."
        case .unregisteredUser:
            return "등록되지 않은 사용자 입니다."
        case .accountAlreadyExist:
            return "이미 존재하는 계정입니다."
        case .undefinedError:
            return "알 수 없는 에러가 발생했습니다."
        }
    }
}
