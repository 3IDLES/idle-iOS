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

    let authRepository: AuthRepository
    let userProfileRepository: UserProfileRepository
    let userInfoLocalRepository: UserInfoLocalRepository
    
    public init(authRepository: AuthRepository, userProfileRepository: UserProfileRepository, userInfoLocalRepository: UserInfoLocalRepository) {
        self.authRepository = authRepository
        self.userProfileRepository = userProfileRepository
        self.userInfoLocalRepository = userInfoLocalRepository
    }
    
    // 센터 회원가입 실행
    public func registerCenterAccount(registerState: CenterRegisterState) -> Single<Result<Void, DomainError>> {
        
        let task = authRepository.requestRegisterCenterAccount(
                managerName: registerState.name,
                phoneNumber: registerState.phoneNumber,
                businessNumber: registerState.businessNumber,
                id: registerState.id,
                password: registerState.password
            )
            .map { [userInfoLocalRepository] _ in
                userInfoLocalRepository.updateUserType(.center)
            }
        return convert(task: task)
    }
    
    // 센터 로그인 실행
    public func loginCenterAccount(id: String, password: String) -> Single<Result<Void, DomainError>> {
        let task = authRepository.requestCenterLogin(id: id, password: password)
            .map { [userInfoLocalRepository] _ in
                userInfoLocalRepository.updateUserType(.center)
            }
        return convert(task: task)
    }
    
    // 요양 보호사 회원가입 실행, 성공한 경우 프로필 Fetch후 저장
    public func registerWorkerAccount(registerState: WorkerRegisterState) -> Single<Result<Void, DomainError>> {
        
        let task = authRepository
            .requestRegisterWorkerAccount(registerState: registerState)
            .flatMap { [userProfileRepository] _ in
                userProfileRepository.getWorkerProfile(mode: .myProfile)
            }
            .map { [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateUserType(.worker)
                userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
            }
        
        return convert(task: task)
    }
    
    // 요양 보호사 로그인 실행, 성공한 경우 프로필 Fetch후 저장
    public func loginWorkerAccount(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>> {
        
        let task = authRepository.requestWorkerLogin(phoneNumber: phoneNumber, authNumber: authNumber)
                .flatMap { [userProfileRepository] _ in
                    userProfileRepository.getWorkerProfile(mode: .myProfile)
                }
                .map { [userInfoLocalRepository] vo in
                    userInfoLocalRepository.updateUserType(.worker)
                    userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
                }
        
        return convert(task: task)
    }
    
    public func checkCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>> {
        convert(task: authRepository.getCenterJoinStatus())
    }
    
    public func setNewPassword(phoneNumber: String, password: String) -> Single<Result<Void, DomainError>> {
        convert(task: authRepository.setNewPassword(phoneNumber: phoneNumber, password: password))
    }
}
