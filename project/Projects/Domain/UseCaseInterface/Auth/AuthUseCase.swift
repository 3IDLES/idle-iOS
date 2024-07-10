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
    /// - returns:
    ///     - Bool, true: 성공, flase: 실패
    func registerCenterAccount(
        registerState: CenterRegisterState
    ) -> Observable<BoolResult>
}
