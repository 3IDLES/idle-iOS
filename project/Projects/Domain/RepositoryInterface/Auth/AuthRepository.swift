//
//  AuthRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import Entity

public protocol AuthRepository: RepositoryBase {
    
    // MARK: Center
    func requestRegisterCenterAccount(managerName: String, phoneNumber: String, businessNumber: String, id: String, password: String) -> Single<Void>
    func requestCenterLogin(id: String, password: String) -> Single<Void>
    func signoutCenterAccount() -> Single<Void>
    func deregisterCenterAccount(reasons: [String], password: String) -> Single<Void>
    func getCenterJoinStatus() -> Single<CenterJoinStatusInfoVO>
    func requestCenterJoin() -> Single<Void>
    func setNewPassword(phoneNumber: String, password: String) -> Single<Void>
    
    
    // MARK: Worker
    func requestRegisterWorkerAccount(registerState: WorkerRegisterState) -> Single<Void>
    func requestWorkerLogin(phoneNumber: String, authNumber: String) -> Single<Void>
    func signoutWorkerAccount() -> Single<Void>
    func deregisterWorkerAccount(reasons: [String]) -> Single<Void>
}
