//
//  RepositoryBase+Extension.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import Entity
import RepositoryInterface

public extension RepositoryBase {
    
    func decodeError<TargetError: CustomError>(of: TargetError.Type, data: Data) -> IdleError {
        
        if let targetError = try? JSONDecoder().decode(ErrorDTO<TargetError>.self, from: data), targetError.errorType != .undefinedError {
            
            return targetError.toEntity()
        }
        
        if let systemError = try? JSONDecoder().decode(ErrorDTO<SystemError>.self, from: data) {
            
            return systemError.toEntity()
        }
        
        return .decodingError(message: "\(String(data: data, encoding: .utf8) ?? "(❌❌ciritical❌❌)") 에러데이터 디코딩 실패")
    }
}
