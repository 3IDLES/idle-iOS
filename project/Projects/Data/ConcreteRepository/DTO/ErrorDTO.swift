//
//  ErrorDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import Entity

class ErrorDTO<T: CustomError>: Decodable {
    
    let code: String
    let timestamp: String
    
    let message: String
    let errorType: T
    
    enum CodingKeys: String, CodingKey {
        case code
        case timestamp
    }
    
    required init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let code = (try? container.decode(String.self, forKey: .code)) ?? T.undefinedError.rawValue
        self.code = code
        
        let timestamp = (try? container.decode(String.self, forKey: .timestamp)) ?? ISO8601DateFormatter().string(from: .init())
        self.timestamp = timestamp
        
        let errorType = T.init(rawValue: code) ?? T.undefinedError
        self.errorType = errorType
        
        let message = errorType.message
        self.message = message
    }
}

extension ErrorDTO {
    
    func toEntity() -> IdleError {
        
        return IdleError(
            code: code,
            message: message,
            errorType: errorType,
            timestamp: timestamp
        )
    }
}
