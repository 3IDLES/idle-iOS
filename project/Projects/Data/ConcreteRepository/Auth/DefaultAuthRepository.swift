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
}

// MARK: Center auth
public extension DefaultAuthRepository {
    
    func requestRegisterCenterAccount(
        managerName: String,
        phoneNumber: String,
        businessNumber: String,
        id: String,
        password: String
    ) -> Single<Void> {
        
        let dto = CenterRegistrationDTO(
            identifier: id,
            password: password,
            phoneNumber: phoneNumber,
            managerName: managerName,
            centerBusinessRegistrationNumber: businessNumber
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        return networkService.request(api: .registerCenterAccount(data: data), with: .plain)
            .map { _ in return () }
    }
    
    func requestCenterLogin(id: String, password: String) -> Single<Void> {
        return networkService.requestDecodable(api: .centerLogin(id: id, password: password), with: .plain)
            .flatMap { [weak self] (token: TokenDTO) in
                
                if let accessToken = token.accessToken, let refreshToken = token.refreshToken {
                    
                    guard let self else { fatalError() }
                    
                    if let _ = try? self.networkService.keyValueStore.saveAuthToken(
                        accessToken: accessToken,
                        refreshToken: refreshToken
                    ) {
                        return .just(())
                    }
                }
                return .error(KeyValueStoreError.tokenSavingFailure)
            }
    }
}

// MARK: Worker auth
public extension DefaultAuthRepository {
    
    
}
