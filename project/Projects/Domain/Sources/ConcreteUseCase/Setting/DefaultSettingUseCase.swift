//
//  DefaultSettingUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/19/24.
//

import Foundation
import Core


import RxSwift

public class DefaultSettingUseCase: SettingScreenUseCase {
    
    // UseCase
    @Injected var notificationTokenUseCase: NotificationTokenUseCase
    
    // Repository
    @Injected var authRepository: AuthRepository
    @Injected var userInfoLocalRepository: UserInfoLocalRepository
    
    public init() { }
    
    // MARK: 회원탈퇴 & 로그아웃
    // 센터 회원탈퇴
    public func deregisterCenterAccount(reasons: [String], password: String) -> RxSwift.Single<Result<Void, DomainError>> {
        
        notificationTokenUseCase
            .deleteNotificationToken()
            .flatMap{ [authRepository] result in
                
                switch result {
                case .success:
                    authRepository
                        .deregisterCenterAccount(reasons: reasons, password: password)
                        .map { [weak self] result in
                            if case .success = result {
                                self?.removeAllLocalData()
                            }
                            return result
                        }
                case .failure:
                    Single.just(result)
                }
            }
    }
    
    // 센터 로그아웃
    public func signoutCenterAccount() -> RxSwift.Single<Result<Void, DomainError>> {
        notificationTokenUseCase
            .deleteNotificationToken()
            .flatMap{ [authRepository] result in
                
                switch result {
                case .success:
                    authRepository
                        .signoutCenterAccount()
                        .map { [weak self] result in
                            if case .success = result {
                                self?.removeAllLocalData()
                            }
                            return result
                        }
                case .failure:
                    Single.just(result)
                }
            }
    }
    
    // 요양보호사 회원탈퇴
    public func deregisterWorkerAccount(reasons: [String]) -> RxSwift.Single<Result<Void, DomainError>> {
        authRepository
            .deregisterWorkerAccount(reasons: reasons)
            .map { [weak self] result in
                if case .success = result {
                    self?.removeAllLocalData()
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
                    self?.removeAllLocalData()
                }
                return result
            }
    }
    
    private func removeAllLocalData() {
        userInfoLocalRepository.removeAllData()
    }
}
