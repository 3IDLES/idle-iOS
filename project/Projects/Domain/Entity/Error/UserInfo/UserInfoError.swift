//
//  UserInfoError.swift
//  Entity
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public enum UserInfoError: String, DomainError {
    
    case textUpdateFailed = "Err-001"
    case imageUpdateFailed = "Err-002"
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        case .undefinedError:
            "❌ \(String(describing: Self.self)) 정의되지 않은 에러타입입니다. ❌"
        case .imageUpdateFailed:
            "이미지 업로드에 실패했습니다."
        case .textUpdateFailed:
            "프로필 업로드에 실패했습니다."
        }
    }
}
