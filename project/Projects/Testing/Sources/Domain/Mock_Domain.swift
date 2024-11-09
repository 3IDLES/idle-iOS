//
//  Mock_Domain.swift
//  Testing
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import Domain


import RxSwift

class MockAuthUseCase: AuthUseCase {
    
    func registerCenterAccount(registerState: Domain.CenterRegisterState) -> RxSwift.Single<Result<Void, Domain.DomainError>> {
        .just(.success(()))
    }
    
    func loginCenterAccount(id: String, password: String) -> RxSwift.Single<Result<Void, Domain.DomainError>> {
        .just(.success(()))
    }
    
    func checkCenterJoinStatus() -> RxSwift.Single<Result<Domain.CenterJoinStatusInfoVO, Domain.DomainError>> {
        .just(.success(.mock))
    }
    
    func setNewPassword(phoneNumber: String, password: String) -> RxSwift.Single<Result<Void, Domain.DomainError>> {
        .just(.success(()))
    }
    
    func registerWorkerAccount(registerState: Domain.WorkerRegisterState) -> RxSwift.Single<Result<Void, Domain.DomainError>> {
        .just(.success(()))
    }
    
    func loginWorkerAccount(phoneNumber: String, authNumber: String) -> RxSwift.Single<Result<Void, Domain.DomainError>> {
        .just(.success(()))
    }
}

extension CenterJoinStatusInfoVO {
    static let mock: Self = .init(
        id: "123",
        managerName: "관리자 성험",
        phoneNumber: "010-1111-2222",
        centerManagerAccountStatus: .approved
    )
}
