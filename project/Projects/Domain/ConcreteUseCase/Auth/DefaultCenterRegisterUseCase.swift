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
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Observable<PhoneNumberAuthResult> {
        filteringDataLayer(
            domainTask: repository.requestPhoneNumberAuthentication(phoneNumber: phoneNumber).asObservable()
        )
    }
    
    public func checkPhoneNumberIsValid(phoneNumber: String) -> Bool {
        let regex = "^\\d{11}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Observable<PhoneNumberAuthResult> {
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
}
