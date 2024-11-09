//
//  MockAuthInputValidationRepository.swift
//  Testing
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import Domain


import RxSwift

class MockAuthInputValidationRepository: AuthInputValidationRepository {
    
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Result<String, DomainError>> {
        .just(.success(""))
    }
    
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Result<String, DomainError>> {
        .just(.success(""))
    }
    
    func requestBusinessNumberAuthentication(businessNumber: String) -> Single<Result<BusinessInfoVO, DomainError>> {
        .just(.success(.mock))
    }
    
    func requestCheckingIdDuplication(id: String) -> Single<Result<Void, DomainError>> {
        .just(.success(()))
    }
}
