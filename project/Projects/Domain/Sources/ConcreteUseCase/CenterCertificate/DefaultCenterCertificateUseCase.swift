//
//  asd.swift
//  ConcreteUseCase
//
//  Created by choijunios on 9/11/24.
//

import Foundation
import Core


import RxSwift

public class DefaultCenterCertificateUseCase: CenterCertificateUseCase {
    
    @Injected var authRepository: AuthRepository
    @Injected var userInfoLocalRepository: UserInfoLocalRepository
    
    public init() { }
    
    public func requestCenterCertificate() -> RxSwift.Single<Result<Void, DomainError>> {
        
        authRepository.requestCenterJoin()
    }
    
    public func getCenterJoinStatus() -> RxSwift.Single<Result<CenterJoinStatusInfoVO, DomainError>> {
        
        authRepository.getCenterJoinStatus()
    }
    
    // 센터 로그아웃
    public func signoutCenterAccount() -> RxSwift.Single<Result<Void, DomainError>> {
        authRepository
            .signoutCenterAccount()
            .map { [weak self] result in
                if case .success = result {
                    self?.userInfoLocalRepository.removeAllData()
                }
                return result
            }
    }
    
    // 요양보호사 로그아웃
    public func signoutWorkerAccount() -> RxSwift.Single<Result<Void, DomainError>> {
        authRepository
            .signoutWorkerAccount()
            .map { [weak self] result in
                if case .success = result {
                    self?.userInfoLocalRepository.removeAllData()
                }
                return result
            }
    }
}
