//
//  AuthInputValidationUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/10/24.
//

import Foundation


import RxSwift

/// 요구사항
///     - #1. 전화번호 인증 요청
///     - #2. 전화번호 유효성 로직
///     - #3. 인증번호 일치여부 확인
///     - #4. 사업자 번호로 정보 조회
///     - #5. 사업자 번호로 유효성 확인
///     - #6. 아이디 유효성 확인
///     - #7. 아이디 중복확인
///     - #8. 패스워드 유효성 확인

public protocol AuthInputValidationUseCase: BaseUseCase {
    
    // #1.
    /// 전화번호 인증 요청
    /// - parameters:
    ///     - PhoneNumber : "000-0000-0000"
    /// - returns:
    ///     - Observable<BoolResult>
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Result<String, DomainError>>
    
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
    ///     - Observable<BoolResult>
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Result<String, DomainError>>
    
    // #4.
    /// 사업자 번호로 해당 사업장 정보 조회
    /// - parameters:
    ///     - businessNumber : String 예시: "123-12-12345"
    /// - returns:
    ///     - Observable<BusinessNumberAuthResult>
    
    // MARK: 사업자 번호 조회
    func requestBusinessNumberAuthentication(businessNumber: String) -> Single<Result<(businessNumber: String, vo: BusinessInfoVO), DomainError>>
    
    // #5.
    /// 사업자 번호 유효성 로직
    /// - parameters:
    ///     - businessNumber : "00000000000"
    /// - returns:
    ///     - Bool, true: 성공, false: 실패
    func checkBusinessNumberIsValid(businessNumber: String) -> Bool
    
    // #6.
    /// 아이디 유효성확인 로직
    /// - parameters:
    ///     - id : "idle1234"
    /// - returns:
    ///     - Bool, true: 가능, flase: 불가능
    func checkIdIsValid(id: String) -> Bool
    
    // #7.
    /// 아이디 중복확인 로직
    /// - parameters:
    ///     - id : "idle1234"
    /// - returns:
    ///     - Bool, true: 가능, flase: 증복
    func requestCheckingIdDuplication(id: String) -> Single<Result<String, DomainError>>
    
    // #8.
    /// 아이디 유효성확인 로직
    /// - parameters:
    ///     - password : "password1234"
    /// - returns:
    ///     - Bool, true: 가능, flase: 불가능
    func checkPasswordIsValid(password: String) -> Bool
    
    // #9.
    /// 이름 유효성 확인 로직
    func checkNameIsValid(name: String) -> Bool
}
