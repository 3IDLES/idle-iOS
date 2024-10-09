//
//  DefaultAuthUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import Core


import RxSwift

public class DefaultAuthUseCase: AuthUseCase {

    // UseCase
    @Injected var notificationTokenUseCase: NotificationTokenUseCase
    
    // Repository
    @Injected var authRepository: AuthRepository
    @Injected var userProfileRepository: UserProfileRepository
    @Injected var userInfoLocalRepository: UserInfoLocalRepository
    
    public init() { }
    
    // 센터 회원가입 실행
    public func registerCenterAccount(registerState: CenterRegisterState) -> Single<Result<Void, DomainError>> {
        
        // #1. 회원가입 실행
        authRepository
            .requestRegisterCenterAccount(
                managerName: registerState.name,
                phoneNumber: registerState.phoneNumber,
                businessNumber: registerState.businessNumber,
                id: registerState.id,
                password: registerState.password
            )
            .map { [userInfoLocalRepository] _ in
                // #2. 유저정보 로컬에 저장
                userInfoLocalRepository.updateUserType(.center)
            }
            .flatMap { [notificationTokenUseCase] _ in
                // #3. 원격알림 토큰을 서버에 전송
                notificationTokenUseCase.setNotificationToken()
            }
    }
    
    // 센터 로그인 실행
    public func loginCenterAccount(id: String, password: String) -> Single<Result<Void, DomainError>> {
        authRepository.requestCenterLogin(id: id, password: password)
            .map { [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateUserType(.center)
            }
            .flatMap { [notificationTokenUseCase] _ in
                // 원격알림 토큰을 서버에 전송
                notificationTokenUseCase.setNotificationToken()
            }
    }
    
    // 요양 보호사 회원가입 실행, 성공한 경우 프로필 Fetch후 저장
    public func registerWorkerAccount(registerState: WorkerRegisterState) -> Single<Result<Void, DomainError>> {
        
        let registerResult = authRepository.requestRegisterWorkerAccount(registerState: registerState)
        
        let registerSuccess = registerResult.compactMap({ $0.value })
        let registerFailure = registerResult.compactMap({ $0.error })
        
        let fetchProfileResult = registerSuccess
            .asObservable()
            .flatMap { [userProfileRepository] _ in
                userProfileRepository
                    .getWorkerProfile(mode: .myProfile)
            }
            .share()
            
        let fetchProfileSuccess = fetchProfileResult.compactMap { $0.value}
        let fetchProfileFailure = fetchProfileResult.compactMap { $0.error}
                
        let saveAndNotificationResult = fetchProfileSuccess
            .map { [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateUserType(.worker)
                userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
            }
            .flatMap { [notificationTokenUseCase] _ in
                // 원격알림 토큰을 서버에 전송
                notificationTokenUseCase.setNotificationToken()
            }
        
        return Observable.merge(
            saveAndNotificationResult,
            Observable
                .merge(registerFailure.asObservable(), fetchProfileFailure.asObservable())
                .map { error -> Result<Void, DomainError> in .failure(error) }
        ).asSingle()
    }
    
    // 요양 보호사 로그인 실행, 성공한 경우 프로필 Fetch후 저장
    public func loginWorkerAccount(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>> {
        
        let loginResult = authRepository.requestWorkerLogin(phoneNumber: phoneNumber, authNumber: authNumber)
                .asObservable()
                .flatMap { [userProfileRepository] _ in
                    userProfileRepository.getWorkerProfile(mode: .myProfile)
                }
                .share()
        
        let loginSuccess = loginResult.compactMap { $0.value }
        let loginFailure = loginResult.compactMap { $0.error }
        
        let tokenTransferResult = loginSuccess
            .asObservable()
            .map { [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateUserType(.worker)
                userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
            }
            .flatMap { [notificationTokenUseCase] _ in
                // 원격알림 토큰을 서버에 전송
                notificationTokenUseCase.setNotificationToken()
            }
        
        return Observable
            .merge(
                tokenTransferResult,
                loginFailure.map({ error -> Result<Void, DomainError> in
                    .failure(error)
                }).asObservable()
            )
            .asSingle()
    }
    
    public func checkCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>> {
        authRepository.getCenterJoinStatus()
    }
    
    public func setNewPassword(phoneNumber: String, password: String) -> Single<Result<Void, DomainError>> {
        authRepository.setNewPassword(phoneNumber: phoneNumber, password: password)
    }
}
