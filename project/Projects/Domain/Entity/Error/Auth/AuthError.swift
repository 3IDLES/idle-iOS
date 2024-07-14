//
//  AuthError.swift
//  Entity
//
//  Created by choijunios on 7/10/24.
//

import Foundation

public enum AuthError: String, DomainError {
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        // MARK: undefinedError
        case .undefinedError:
            "❌ 정의되지 않은 에러타입입니다. ❌"
        }
    }
}
