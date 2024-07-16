//
//  AuthError.swift
//  Entity
//
//  Created by choijunios on 7/10/24.
//

import Foundation

public enum AuthError: String, DomainError {
    
    case accountAlreadyExist="CENTER-002"
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        case .accountAlreadyExist:
            "이미 존재하는 계정입니다."
        case .undefinedError:
            "❌ 정의되지 않은 에러타입입니다. ❌"
        }
    }
}
