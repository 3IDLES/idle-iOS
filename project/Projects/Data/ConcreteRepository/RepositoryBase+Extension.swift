//
//  RepositoryBase+Extension.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import Entity
import RepositoryInterface
import Moya
import NetworkDataSource

extension RepositoryBase {
    
    func decodeError<TargetError: CustomError>(of: TargetError.Type, data: Data) -> IdleError {
        
        if let targetError = try? JSONDecoder().decode(ErrorDTO<TargetError>.self, from: data), targetError.errorType != .undefinedError {
            
            return targetError.toEntity()
        }
        
        if let systemError = try? JSONDecoder().decode(ErrorDTO<SystemError>.self, from: data) {
            
            return systemError.toEntity()
        }
        
        return .decodingError(message: "\(String(data: data, encoding: .utf8) ?? "(❌❌ciritical❌❌)") 에러데이터 디코딩 실패")
    }
    
    func decodeData<DTO: Decodable>(data: Data) -> DTO {
        
        return try! JSONDecoder().decode(DTO.self, from: data)
    }
    
    func filterNetworkConnection(_ error: Error) -> URLError? {
        
        // 데이터소스 에러
        if let dataSourceError = error as? DataSourceError {
            #if DEBUG
            print("데이터 소스 에러: \(error.localizedDescription)")
            #endif
            return nil
        }
        
        guard let moyaError = error as? MoyaError, case .underlying(let err, _) = moyaError, let afError = err.asAFError, afError.isSessionTaskError else {
            return nil
        }
        
        // 네트워크 미연결 에러
        return URLError.init(.notConnectedToInternet)
    }
    
}
