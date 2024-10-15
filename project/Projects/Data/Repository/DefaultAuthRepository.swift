//
//  DefaultAuthRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import Domain
import DataSource
import Core


import RxSwift

public class DefaultAuthRepository: AuthRepository {
    
    @Injected var keyValueStore: KeyValueStore
    
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
    ) -> Single<Result<Void, DomainError>> {
        
        let dto = CenterRegistrationDTO(
            identifier: id,
            password: password,
            phoneNumber: phoneNumber,
            managerName: managerName,
            centerBusinessRegistrationNumber: businessNumber
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        let dataTask = networkService.request(api: .registerCenterAccount(data: data), with: .plain)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    func requestCenterLogin(id: String, password: String) -> Single<Result<Void, DomainError>> {
        let dataTask = networkService.requestDecodable(api: .centerLogin(id: id, password: password), with: .plain)
            .flatMap { [unowned self] in
                saveTokenToStore(token: $0)
            }
        
        return convertToDomain(task: dataTask)
    }
    
    func signoutCenterAccount() -> Single<Result<Void, DomainError>> {
        let dataTask = networkService
            .request(api: .signoutCenterAccount, with: .withToken)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    func deregisterCenterAccount(reasons: [String], password: String) -> Single<Result<Void, DomainError>> {
        
        let reasonString = reasons.joined(separator: "|")
        
        let dataTask = networkService
            .request(
                api: .deregisterCenterAccount(
                    reason: reasonString,
                    password: password
                ),
                with: .withToken
            )
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    func getCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>> {
        let dataTask = networkService
            .request(api: .centerJoinStatus, with: .withToken)
            .map(CenterJoinStatusInfoVO.self)
        
        return convertToDomain(task: dataTask)
    }
    
    func requestCenterJoin() -> Single<Result<Void, DomainError>> {
        let dataTask = networkService
            .request(api: .requestCenterJoin, with: .withToken)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    func setNewPassword(phoneNumber: String, password: String) -> Single<Result<Void, DomainError>> {
        let dataTask = networkService
            .request(api: .makeNewPassword(phoneNumber: phoneNumber, newPassword: password), with: .plain)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
}

// MARK: Worker auth
public extension DefaultAuthRepository {
    
    /// 요양보호사의 경우 회원가입시 곧바로 토큰을 발급받습니다.
    func requestRegisterWorkerAccount(registerState: WorkerRegisterState) -> Single<Result<Void, DomainError>> {
        let dto = WorkerRegistrationDTO(
            carerName: registerState.name,
            birthYear: registerState.birthYear,
            genderType: registerState.gender,
            phoneNumber: registerState.phoneNumber,
            roadNameAddress: registerState.addressInformation.roadAddress,
            lotNumberAddress: registerState.addressInformation.jibunAddress
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        let dataTask = networkService.requestDecodable(api: .registerWorkerAccount(data: data), with: .plain)
            .flatMap { [unowned self] in saveTokenToStore(token: $0) }
        
        return convertToDomain(task: dataTask)
    }
    
    func requestWorkerLogin(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>> {
        let dataTask = networkService.requestDecodable(api: .workerLogin(phoneNumber: phoneNumber, verificationNumber: authNumber), with: .plain)
            .flatMap { [unowned self] in saveTokenToStore(token: $0) }
        
        return convertToDomain(task: dataTask)
    }
    
    func signoutWorkerAccount() -> Single<Result<Void, DomainError>> {
        let dataTask = networkService
            .request(api: .signoutWorkerAccount, with: .withToken)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    func deregisterWorkerAccount(reasons: [String]) -> Single<Result<Void, DomainError>> {
        let reasonString = reasons.joined(separator: "|")
        let dataTask = networkService
            .request(
                api: .deregisterWorkerAccount(reason: reasonString),
                with: .withToken
            )
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
}

// MARK: Token management
extension DefaultAuthRepository {
    
    private func saveTokenToStore(token: TokenDTO) -> Single<Void> {
        
        guard let accessToken = token.accessToken, let refreshToken = token.refreshToken else {
            return .error(KeyValueStoreError.tokenSavingFailure)
        }
        do {
            try keyValueStore.saveAuthToken(accessToken: accessToken, refreshToken: refreshToken)
            return .just(())
        } catch {
            return .error(KeyValueStoreError.tokenSavingFailure)
        }
    }
}
