//
//  UserInfoError.swift
//  Entity
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public enum UserInfoError: String, DomainError {
    
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        case .undefinedError:
            "❌ \(String(describing: Self.self)) 정의되지 않은 에러타입입니다. ❌"
        }
    }
}
