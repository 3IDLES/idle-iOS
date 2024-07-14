//
//  AuthUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxSwift
import Entity

/// 요구사항
///     - #1. 센터 회원가입 실행
///     - #2. 센터 로그인 실행
///     - #3. 샌터 회원 탈퇴
///
///     - #4. 요양보호사 회원가입 실행
///     - #5. 요양보호사 로그인 실행
///     - #5. 요양보호사 회원탈퇴 실행

public protocol AuthUseCase: UseCaseBase {
    
    // #1.
    /// 센터 회원가입 실행
    /// - parameters:
    ///     - registerState: CenterRegisterState
    func registerCenterAccount(
        registerState: CenterRegisterState
    ) -> Single<Result<Void, AuthError>>
    
    // #2.
    /// 센터 로그인 실행
    /// - parameters:
    ///     - id: String
    ///     - password: String
    func loginCenterAccount(
        id: String,
        password: String
    ) -> Single<Result<Void, AuthError>>
}
