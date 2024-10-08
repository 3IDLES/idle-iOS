//
//  AuthInputValidationRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/8/24.
//

import Foundation


import RxSwift

public protocol AuthInputValidationRepository: RepositoryBase {
    
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Result<Void, DomainError>>
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>>
    func requestBusinessNumberAuthentication(businessNumber: String) -> Single<Result<BusinessInfoVO, DomainError>>
    func requestCheckingIdDuplication(id: String) -> Single<Result<Void, DomainError>>
}
