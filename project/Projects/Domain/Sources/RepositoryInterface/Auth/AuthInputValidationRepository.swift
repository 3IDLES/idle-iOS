//
//  AuthInputValidationRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/8/24.
//

import Foundation


import RxSwift

public protocol AuthInputValidationRepository: RepositoryBase {
    
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Void>
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Void>
    func requestBusinessNumberAuthentication(businessNumber: String) -> Single<BusinessInfoVO>
    func requestCheckingIdDuplication(id: String) -> Single<Void>
}
