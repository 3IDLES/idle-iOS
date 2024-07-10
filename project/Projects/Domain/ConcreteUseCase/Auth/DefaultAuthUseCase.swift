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

public class DefualtAuthseeCase: AuthUseCase {
    
    let repository: AuthRepository
    
    public init(repository: AuthRepository) {
        self.repository = repository
    }
    
    // MARK: 센터 회원가입 실행
    public func registerCenterAccount(registerState: Entity.CenterRegisterState) -> RxSwift.Observable<Entity.BoolResult> {
        filteringDataLayer(
            domainTask: repository.requestRegisterCenterAccount(
                managerName: registerState.name!,
                phoneNumber: registerState.phoneNumber!,
                businessNumber: registerState.businessNumber!,
                id: registerState.id!,
                password: registerState.password!
            ).asObservable()
        )
    }
    
    // MARK: 센터 로그인 실행
    public func loginCenterAccount(id: String, password: String) -> RxSwift.Observable<Entity.BoolResult> {
        filteringDataLayer(
            domainTask: repository.requestCenterLogin(id: id, password: password).asObservable()
        )
    }
}
