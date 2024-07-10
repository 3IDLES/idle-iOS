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
    
    // MARK: static Local Error
    public static func decodingError(message: String) -> IdleError {
        IdleError(
            code: "Local-001",
            message: message,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    public static var unknownError: IdleError {
        IdleError(
            code: "Local-002",
            message: "처리되지 않은 에러입니다. 관리자에게 문의하세요.",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    public static var networkError: IdleError {
        IdleError(
            code: "Local-003",
            message: "네트워크 에러입니다. 네트워크 연결을 확인해주세요.",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    public static var localSaveError: IdleError {
        IdleError(
            code: "Local-004",
            message: "토큰을 로컬환경에 저장하는데 실패했습니다.",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    // MARK: static ServerError
    public static var systemError: IdleError {
        IdleError(
            code: "SYSTEM-001",
            message: "서버에러 입니다.",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }
}
