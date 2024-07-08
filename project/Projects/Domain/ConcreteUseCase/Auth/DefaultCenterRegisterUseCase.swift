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
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<PhoneNumberAuthResult> {
        
        return repository.requestPhoneNumberAuthentication(phoneNumber: phoneNumber)
    }
    
    public func checkPhoneNumberIsValid(phoneNumber: String) -> Bool {
        let regex = "^\\d{11}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<PhoneNumberAuthResult> {
        
        return repository.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
    }
}
