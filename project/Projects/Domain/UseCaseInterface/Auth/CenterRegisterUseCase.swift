//
//  CenterRegisterUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RxSwift
import Entity

/// 요구사항
///     - #1. 전화번호 인증 요청
///     - #2. 전화번호 유효성 로직
///     - #3. 인증번호 일치여부 확인
///     - #4. 사업자 번호로 정보 조회
///     - #5. 아이디 중복확인

public protocol CenterRegisterUseCase {
    
    typealias PhoneNumberAuthResult = Result<Bool, IdleError>
    
    // #1.
    /// 전화번호 인증 요청ㄴ
    /// - parameters:
    ///     - PhoneNumber : "000-0000-0000"
    /// - returns:
    ///     - Single<Bool>, true: 성공, false: 실패
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<PhoneNumberAuthResult>
    
    // #2.
    /// 전화번호 인증 요청
    /// - parameters:
    ///     - PhoneNumber : "000-0000-0000"
    /// - returns:
    ///     - Bool, true: 성공, false: 실패
    func checkPhoneNumberIsValid(phoneNumber: String) -> Bool
    
    // #3.
    /// 인증번호 일치여부 확인
    /// - parameters:
    ///     - PhoneNumber : String 예시: "000-0000-0000"
    ///     - authNumber : String 예시 "000000"
    /// - returns:
    ///     - Single<Bool>, true: 성공, false: 실패
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<PhoneNumberAuthResult>
    
    
}
