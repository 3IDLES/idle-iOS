//
//  CenterRegisterRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RxSwift
import Entity

public protocol CenterRegisterRepository: RepositoryBase {
    
    typealias PhoneNumberAuthResult = Result<Bool, IdleError>
    
    func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<PhoneNumberAuthResult>
    func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<PhoneNumberAuthResult>
}
