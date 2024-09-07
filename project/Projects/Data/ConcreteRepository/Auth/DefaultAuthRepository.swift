//
//  DefaultAuthRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxSwift
import RepositoryInterface
import DataSource
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
    
    func signoutCenterAccount() -> RxSwift.Single<Void> {
        networkService
            .request(api: .signoutCenterAccount, with: .withToken)
            .map {  _ in }
    }
    
    func deregisterCenterAccount(reasons: [DeregisterReasonVO], password: String) -> RxSwift.Single<Void> {
        
        let reasonString = reasons.map { $0.reasonText }.joined(separator: "|")
        
        return networkService
            .request(
                api: .deregisterCenterAccount(
                    reason: reasonString,
                    password: password
                ),
                with: .withToken
            )
            .map { _ in }
    }
    
    func getCenterJoinStatus() -> RxSwift.Single<CenterJoinStatusInfoVO> {
        networkService
            .request(api: .centerJoinStatus, with: .withToken)
            .map(CenterJoinStatusInfoVO.self)
    }
}

// MARK: Worker auth
public extension DefaultAuthRepository {
    
    /// 요양보호사의 경우 회원가입시 곧바로 토큰을 발급받습니다.
    func requestRegisterWorkerAccount(registerState: WorkerRegisterState) -> Single<Void> {
        let dto = WorkerRegistrationDTO(
            carerName: registerState.name,
            birthYear: registerState.birthYear,
            genderType: registerState.gender,
            phoneNumber: registerState.phoneNumber,
            roadNameAddress: registerState.addressInformation.roadAddress,
            lotNumberAddress: registerState.addressInformation.jibunAddress
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        return networkService.requestDecodable(api: .registerWorkerAccount(data: data), with: .plain)
            .flatMap { [unowned self] in saveTokenToStore(token: $0) }
    }
    
    func requestWorkerLogin(phoneNumber: String, authNumber: String) -> Single<Void> {
        return networkService.requestDecodable(api: .workerLogin(phoneNumber: phoneNumber, verificationNumber: authNumber), with: .plain)
            .flatMap { [unowned self] in saveTokenToStore(token: $0) }
    }
    
    func signoutWorkerAccount() -> RxSwift.Single<Void> {
        networkService
            .request(api: .signoutWorkerAccount, with: .withToken)
            .map {  _ in }
    }
    
    func deregisterWorkerAccount(reasons: [Entity.DeregisterReasonVO]) -> RxSwift.Single<Void> {
        let reasonString = reasons.map { $0.reasonText }.joined(separator: "|")
        
        return networkService
            .request(
                api: .deregisterWorkerAccount(
                    reason: reasonString
                ),
                with: .withToken
            )
            .map { _ in }
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
