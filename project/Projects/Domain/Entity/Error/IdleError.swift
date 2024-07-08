//
//  IdleError.swift
//  Entity
//
//  Created by choijunios on 7/8/24.
//

import Foundation

public class IdleError: Error {
    
    public let code: String
    public let message: String
    public let errorType: (any CustomError)?
    public let timestamp: String
    
    public init(
        code: String,
        message: String,
        errorType: (any CustomError)? = nil,
        timestamp: String
    ) {
        self.code = code
        self.message = message
        self.timestamp = timestamp
        self.errorType = errorType
    }
    
    public static func decodingError(message: String) -> IdleError {
        IdleError(
            code: "Err-001",
            message: message,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    public static func unknownError() -> IdleError {
        IdleError(
            code: "Err-002",
            message: "처리되지 않은 에러입니다. 관리자에게 문의하세요.",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    public static func systemError() -> IdleError {
        IdleError(
            code: "SYSTEM-001",
            message: "서버에러 입니다.",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}
