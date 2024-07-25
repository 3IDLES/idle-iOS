//
//  DefaultAuthUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import UseCaseInterface
import RepositoryInterface
import RxSwift
import Entity

public class DefaultAuthUseCase: AuthUseCase {
    
    let repository: AuthRepository
    
    public init(repository: AuthRepository) {
        self.repository = repository
    }
    
    /// 센터 회원가입 실행
    public func registerCenterAccount(registerState: CenterRegisterState) -> Single<Result<Void, AuthError>> {
        convert(
            task: repository.requestRegisterCenterAccount(
                managerName: registerState.name,
                phoneNumber: registerState.phoneNumber,
                businessNumber: registerState.businessNumber,
                id: registerState.id,
                password: registerState.password
        )) { [unowned self] error in toDomainError(error: error) }
    }
    
    /// 센터 로그인 실행
    public func loginCenterAccount(id: String, password: String) -> Single<Result<Void, AuthError>> {
        convert(task: repository.requestCenterLogin(id: id, password: password)) { [unowned self] error in
            toDomainError(error: error)
        }
    }
    
    /// 요양 보호사 회원가입 실행
    public func registerWorkerAccount(registerState: WorkerRegisterState) -> Single<Result<Void, AuthError>> {
        convert(
            task: repository.requestRegisterWorkerAccount(registerState: registerState)) { [unowned self] error in toDomainError(error: error)
            }
    }
    
    /// 요양 보호사 로그인 실행
    public func loginWorkerAccount(phoneNumber: String, authNumber: String) -> Single<Result<Void, AuthError>> {
        convert(
            task: repository.requestWorkerLogin(phoneNumber: phoneNumber, authNumber: authNumber)) { [unowned self] error in toDomainError(error: error)
            }
    }
}
