//
//  DefaultAuthInputValidationUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefaultAuthInputValidationUseCase: AuthInputValidationUseCase {

    let repository: AuthInputValidationRepository
    
    public init(repository: AuthInputValidationRepository) {
        self.repository = repository
    }
    
    // MARK: 이름 인증
    public func checkNameIsValid(name: String) -> Bool {
        return name.count >= 2
    }
    
    
    // MARK: 전화번호 인증
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Result<Void, InputValidationError>> {
        convert(task: self.repository.requestPhoneNumberAuthentication(phoneNumber: phoneNumber)) { [unowned self] error in
            toDomainError(error: error)
        }
    }
    
    public func checkPhoneNumberIsValid(phoneNumber: String) -> Bool {
        let regex = "^\\d{11}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Result<Void, InputValidationError>> {
        convert(task: repository.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)) { [unowned self] error in
            toDomainError(error: error)
        }
    }
    
    // MARK: 사업자 번호 인증
    public func requestBusinessNumberAuthentication(businessNumber: String) -> Single<Result<BusinessInfoVO, InputValidationError>> {
        convert(task: repository.requestBusinessNumberAuthentication(businessNumber: businessNumber)) { [unowned self] error in
            toDomainError(error: error)
        }
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
    
    public func requestCheckingIdDuplication(id: String) -> Single<Result<Void, InputValidationError>> {
        convert(task: repository.requestCheckingIdDuplication(id: id)) { [unowned self] error in
            toDomainError(error: error)
        }
    }
    
    public func checkPasswordIsValid(password: String) -> Bool {
        let passwordLengthAndCharRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*()_+=-]{8,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordLengthAndCharRegex)
        
        return predicate.evaluate(with: password)
    }
}
