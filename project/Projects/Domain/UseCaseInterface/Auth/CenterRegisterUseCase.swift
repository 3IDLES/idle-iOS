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
///     - #5. 사업자 번호로 유효성 확인
///     - #6. 아이디 중복확인

public protocol CenterRegisterUseCase: UseCaseBase {
    
    // #1.
    /// 전화번호 인증 요청
    /// - parameters:
    ///     - PhoneNumber : "000-0000-0000"
    /// - returns:
    ///     - Observable<PhoneNumberAuthResult>
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Observable<PhoneNumberAuthResult>
    
    // #2.
    /// 전화번호 유효성 로직
    /// - parameters:
    ///     - PhoneNumber : "00000000000"
    /// - returns:
    ///     - Bool, true: 성공, false: 실패
    func checkPhoneNumberIsValid(phoneNumber: String) -> Bool
    
    // #3.
    /// 인증번호 일치여부 확인
    /// - parameters:
    ///     - PhoneNumber : String 예시: "000-0000-0000"
    ///     - authNumber : String 예시 "000000"
    /// - returns:
    ///     - Observable<PhoneNumberAuthResult>
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Observable<PhoneNumberAuthResult>
    
    // #4.
    /// 사업자 번호로 해당 사업장 정보 조회
    /// - parameters:
    ///     - businessNumber : String 예시: "123-12-12345"
    /// - returns:
    ///     - Observable<BusinessNumberAuthResult>
    
    // MARK: 사업자 번호 조회
    func requestBusinessNumberAuthentication(businessNumber: String) -> Observable<BusinessNumberAuthResult>
    
    // #5.
    /// 사업자 번호 유효성 로직
    /// - parameters:
    ///     - businessNumber : "00000000000"
    /// - returns:
    ///     - Bool, true: 성공, false: 실패
    func checkBusinessNumberIsValid(businessNumber: String) -> Bool
}
