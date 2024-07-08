//
//  SystemError.swift
//  Entity
//
//  Created by choijunios on 7/8/24.
//

import Foundation

public enum SystemError: String, CustomError {
    
    case invalidParameter = "API-001"
    case undefinedError = "Err-000"
    
    public var message: String {
        switch self {
        case .invalidParameter:
            "API 요청 시, 잘못된 parameter를 입력한 경우 발생합니다."
        case .undefinedError:
            "정의되지 않은 에러타입입니다."
        }
    }
}
