//
//  RecruitmentPostError.swift
//  Entity
//
//  Created by choijunios on 8/9/24.
//

import Foundation

public enum RecruitmentPostError: String, DomainError {
    
    // undefinedError
    case undefinedError="Err-000"
    
    public var message: String {
        switch self {
        case .undefinedError:
            "알 수 없는 오류가 발생했습니다."
        }
    }
}
