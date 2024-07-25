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
            .flatMap { [unowned self] in saveTokenToStore(token: $0) }
    }
}

// MARK: Worker auth
public extension DefaultAuthRepository {
    
    func requestRegisterWorkerAccount(registerState: WorkerRegisterState) -> Single<Void> {
        let dto = WorkerRegistrationDTO(
            carerName: registerState.name,
            birthYear: registerState.birthYear,
            genderType: registerState.gender,
            phoneNumber: registerState.phoneNumber,
            roadNameAddress: registerState.addressInformation.roadAddress,
            lotNumberAddress: registerState.addressInformation.jibunAddress,
            longitude: registerState.latitude,
            latitude: registerState.logitude
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        return networkService.request(api: .registerWorkerAccount(data: data), with: .plain)
            .map { _ in return () }
    }
    
    func requestWorkerLogin(phoneNumber: String, authNumber: String) -> Single<Void> {
        return networkService.requestDecodable(api: .workerLogin(phoneNumber: phoneNumber, verificationNumber: authNumber), with: .plain)
            .flatMap { [unowned self] in saveTokenToStore(token: $0) }
    }
}

// MARK: Token management
extension DefaultAuthRepository {
    
    private func saveTokenToStore(token: TokenDTO) -> Single<Void>{
        
        if let accessToken = token.accessToken, let refreshToken = token.refreshToken {
            
            if let _ = try? networkService.keyValueStore.saveAuthToken(
                accessToken: accessToken,
                refreshToken: refreshToken
            ) {
                return .just(())
            }
        }
        return .error(KeyValueStoreError.tokenSavingFailure)
    }
}
