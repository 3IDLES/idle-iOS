//
//  DefaultCenterRegisterUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefaultCenterRegisterUseCase: CenterRegisterUseCase {

    let repository: CenterRegisterRepository
    
    public init(repository: CenterRegisterRepository) {
        self.repository = repository
    }
    
    // MARK: 전화번호 인증
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Observable<BoolResult> {
        filteringDataLayer(
            domainTask: repository.requestPhoneNumberAuthentication(phoneNumber: phoneNumber).asObservable()
        )
    }
    
    public func checkPhoneNumberIsValid(phoneNumber: String) -> Bool {
        let regex = "^\\d{11}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Observable<BoolResult> {
        filteringDataLayer(
            domainTask: repository.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber).asObservable()
        )
    }
    
    // MARK: 사업자 번호 인증
    public func requestBusinessNumberAuthentication(businessNumber: String) -> Observable<BusinessNumberAuthResult> {
        filteringDataLayer(
            domainTask: repository.requestBusinessNumberAuthentication(businessNumber: businessNumber).asObservable()
        )
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
    
    public func requestCheckingIdDuplication(id: String) -> Observable<BoolResult> {
        filteringDataLayer(
            domainTask: repository.requestCheckingIdDuplication(id: id).asObservable()
        )
    }
    
    public func checkPasswordIsValid(password: String) -> Bool {
        let passwordLengthAndCharRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*()_+=-]{8,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordLengthAndCharRegex)
        
        return predicate.evaluate(with: password)
    }
    
    // MARK: 로그인 실행
    public func registerCenterAccount(registerState: CenterRegisterState) -> Observable<BoolResult> {
        
        filteringDataLayer(
            domainTask: repository.requestRegisterCenterAccount(
                managerName: registerState.name!,
                phoneNumber: registerState.phoneNumber!,
                businessNumber: registerState.businessNumber!,
                id: registerState.id!,
                password: registerState.password!
            ).asObservable()
        )
    }
}
