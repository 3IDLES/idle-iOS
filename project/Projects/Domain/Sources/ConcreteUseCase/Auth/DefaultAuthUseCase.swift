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
        
        authRepository
            .requestRegisterWorkerAccount(registerState: registerState)
            .flatMap { [userProfileRepository] _ in
                userProfileRepository.getWorkerProfile(mode: .myProfile)
            }
            .map { [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateUserType(.worker)
                userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
            }
            .flatMap { [notificationTokenUseCase] _ in
                // 원격알림 토큰을 서버에 전송
                notificationTokenUseCase.setNotificationToken()
            }
    }
    
    // 요양 보호사 로그인 실행, 성공한 경우 프로필 Fetch후 저장
    public func loginWorkerAccount(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>> {
        
        authRepository.requestWorkerLogin(phoneNumber: phoneNumber, authNumber: authNumber)
                .flatMap { [userProfileRepository] _ in
                    userProfileRepository.getWorkerProfile(mode: .myProfile)
                }
                .map { [userInfoLocalRepository] vo in
                    userInfoLocalRepository.updateUserType(.worker)
                    userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
                }
                .flatMap { [notificationTokenUseCase] _ in
                    // 원격알림 토큰을 서버에 전송
                    notificationTokenUseCase.setNotificationToken()
                }
    }
    
    public func checkCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>> {
        convert(task: authRepository.getCenterJoinStatus())
    }
    
    public func setNewPassword(phoneNumber: String, password: String) -> Single<Result<Void, DomainError>> {
        convert(task: authRepository.setNewPassword(phoneNumber: phoneNumber, password: password))
    }
}
