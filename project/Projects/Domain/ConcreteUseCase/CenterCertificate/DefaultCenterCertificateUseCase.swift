//
//  asd.swift
//  ConcreteUseCase
//
//  Created by choijunios on 9/11/24.
//

import Foundation
import Entity
import UseCaseInterface
import RepositoryInterface

import RxSwift

public class DefaultCenterCertificateUseCase: CenterCertificateUseCase {
    
    let authRepository: AuthRepository
    let userInfoLocalRepository: UserInfoLocalRepository
    
    public init(authRepository: AuthRepository, userInfoLocalRepository: UserInfoLocalRepository) {
        self.authRepository = authRepository
        self.userInfoLocalRepository = userInfoLocalRepository
    }
    
    public func requestCenterCertificate() -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        
        convert(task: authRepository.requestCenterJoin())
    }
    
    // 센터 로그아웃
    public func signoutCenterAccount() -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        let task = authRepository
            .signoutCenterAccount()
            .map { [weak self] _ in
                self?.removeAllLocalData()
                
                return ()
            }
        return convert(task: task)
    }
    
    // 요양보호사 로그아웃
    public func signoutWorkerAccount() -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        let task = authRepository
            .signoutWorkerAccount()
            .map { [weak self] _ in
                self?.removeAllLocalData()
                
                return ()
            }
        return convert(task: task)
    }
    private func removeAllLocalData() {
        userInfoLocalRepository.removeAllData()
    }
}
