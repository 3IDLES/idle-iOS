//
//  AuthUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxSwift
import Entity

public protocol AuthUseCase: BaseUseCase {
    
    
    /// 센터 회원가입 실행
    /// - parameters:
    ///     - registerState: CenterRegisterState
    func registerCenterAccount(
        registerState: CenterRegisterState
    ) -> Single<Result<Void, DomainError>>
    
    
    /// 센터 로그인 실행
    /// - parameters:
    ///     - id: String
    ///     - password: String
    func loginCenterAccount(
        id: String,
        password: String
    ) -> Single<Result<Void, DomainError>>
    
    /// 센터 인증여부 확인
    func checkCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>>
    
    
    /// 센터 비밀번호 재설정
    func setNewPassword(phoneNumber: String, password: String) -> Single<Result<Void, DomainError>>
    
    
    /// 요양 보호사 회원가입 실행
    func registerWorkerAccount(
        registerState: WorkerRegisterState
    ) -> Single<Result<Void, DomainError>>
    
    
    /// 요양 보호사 로그인 실행
    func loginWorkerAccount(
        phoneNumber: String,
        authNumber: String
    ) -> Single<Result<Void, DomainError>>
}
