//
//  DefaultAuthInputValidationUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import Core


import RxSwift

public class DefaultAuthInputValidationUseCase: AuthInputValidationUseCase {

    @Injected var repository: AuthInputValidationRepository
    
    public init() { }
    
    // MARK: 이름 인증
    public func checkNameIsValid(name: String) -> Bool {
        return name.count >= 2
    }
    
    
    // MARK: 전화번호 인증
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Result<String, DomainError>> {
        repository
            .requestPhoneNumberAuthentication(phoneNumber: phoneNumber)
    }
    
    public func checkPhoneNumberIsValid(phoneNumber: String) -> Bool {
        let regex = "^\\d{11}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Result<String, DomainError>> {
        repository
            .authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
    }
    
    // MARK: 사업자 번호 인증
    public func requestBusinessNumberAuthentication(businessNumber: String) -> Single<Result<BusinessInfoVO, DomainError>> {
        repository
            .requestBusinessNumberAuthentication(businessNumber: businessNumber)
    }
    
    public func checkBusinessNumberIsValid(businessNumber: String) -> Bool {
        let regex = "^\\d{10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: businessNumber)
    }
    
    // MARK: 아이디 비밀번호 유효성 검사
    public func checkIdIsValid(id: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9]{6,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        
        return predicate.evaluate(with: id)
    }
    
    public func requestCheckingIdDuplication(id: String) -> Single<Result<Void, DomainError>> {
        repository
            .requestCheckingIdDuplication(id: id)
    }
    
    public func checkPasswordIsValid(password: String) -> PasswordValidationState {
        
        // 1. 8자 ~ 20자 사이
        let lengthRegex = "^.{8,20}$"
        let lengthIsValid = evaluateStringWith(regex: lengthRegex, targetString: password)
        
        // 2. 영문자와 숫자 반드시 하나씩 포함
        let letterAndNumberRegex = "^(?=.*[A-Za-z])(?=.*[0-9]).*$"
        let letterAndNumberIsValid = evaluateStringWith(regex: letterAndNumberRegex, targetString: password)
        
        // 3. 공백 문자 사용 금지
        let noWhitespaceRegex = "^\\S*$"
        let noWhitespaceIsValid = evaluateStringWith(regex: noWhitespaceRegex, targetString: password)
        
        // 4. 연속된 문자 3개 이상 사용 금지
        let noTripleRepeatedCharsRegex = "(.)\\1{2,}"
        let noTripleRepeatedCharsIsValid = !evaluateStringWith(regex: noTripleRepeatedCharsRegex, targetString: password)
        
        return PasswordValidationState(
            characterCount: lengthIsValid ? .valid : .invalid,
            alphabetAndNumberIncluded: letterAndNumberIsValid ? .valid : .invalid,
            noEmptySpace: noWhitespaceIsValid ? .valid : .invalid,
            unsuccessiveSame3words: noTripleRepeatedCharsIsValid ? .valid : .invalid
        )
    }
                                       
    private func evaluateStringWith(regex: String, targetString: String) -> Bool {
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: targetString)
    }
}
