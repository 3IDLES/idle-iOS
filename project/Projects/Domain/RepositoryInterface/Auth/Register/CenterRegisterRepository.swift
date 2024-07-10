//
//  CenterRegisterRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RxSwift
import Entity

public protocol AuthInputValidationRepository: RepositoryBase {
    
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<BoolResult>
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<BoolResult>
    func requestBusinessNumberAuthentication(businessNumber: String) -> Single<BusinessNumberAuthResult>
    func requestCheckingIdDuplication(id: String) -> Single<BoolResult>
}
