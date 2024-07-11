//
//  DefaultAuthRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxSwift
import RepositoryInterface
import NetworkDataSource
import Entity

public class DefaultAuthRepository: AuthRepository {

    let networkService = AuthService()
    
    public init() { }
    
    public func requestRegisterCenterAccount(managerName: String, phoneNumber: String, businessNumber: String, id: String, password: String) -> RxSwift.Single<Entity.BoolResult> {
        
        let dto = CenterRegistrationDTO(
            identifier: id,
            password: password,
            phoneNumber: phoneNumber,
            managerName: managerName,
            centerBusinessRegistrationNumber: businessNumber
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        return networkService.requestWithoutToken(api: .registerCenterAccount(data: data))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BoolResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 201:
                    return .success(true)
                default:
                    return .failure(self.decodeError(of: AuthError.self, data: response.data))
                }
            }
    }
    
    public func requestCenterLogin(id: String, password: String) -> RxSwift.Single<Entity.BoolResult> {
        
        return networkService.requestWithoutToken(api: .centerLogin(id: id, password: password))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BoolResult.failure(.unknownError) }
                
                if response.statusCode == 200 {
                    
                    if let dict = try JSONSerialization.jsonObject(with: response.data) as? [String: String],
                       let accessToken = dict["accessToken"],
                       let refreshToken = dict["refreshToken"] {
                        
                        // 토큰처리
                        do {
                            try self.networkService.keyValueStore.saveAuthToken(
                                accessToken: accessToken,
                                refreshToken: refreshToken
                            )
                            #if DEBUG
                            print("\(#function) ✅ 토큰 저장성공")
                            #endif
                            
                            return .success(true)
                        } catch {
                            
                            return .failure(.localSaveError)
                        }
                    }
                }
                return .failure(self.decodeError(of: AuthError.self, data: response.data))
            }
    }
}
