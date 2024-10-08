//
//  AuthRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/10/24.
//

import RxSwift

public protocol AuthRepository: RepositoryBase {
    
    // MARK: Center
    func requestRegisterCenterAccount(managerName: String, phoneNumber: String, businessNumber: String, id: String, password: String) -> Single<Result<Void, DomainError>>
    func requestCenterLogin(id: String, password: String) -> Single<Result<Void, DomainError>>
    func signoutCenterAccount() -> Single<Result<Void, DomainError>>
    func deregisterCenterAccount(reasons: [String], password: String) -> Single<Result<Void, DomainError>>
    func getCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>>
    func requestCenterJoin() -> Single<Result<Void, DomainError>>
    func setNewPassword(phoneNumber: String, password: String) -> Single<Result<Void, DomainError>>
    
    
    // MARK: Worker
    func requestRegisterWorkerAccount(registerState: WorkerRegisterState) -> Single<Result<Void, DomainError>>
    func requestWorkerLogin(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>>
    func signoutWorkerAccount() -> Single<Result<Void, DomainError>>
    func deregisterWorkerAccount(reasons: [String]) -> Single<Result<Void, DomainError>>
}
