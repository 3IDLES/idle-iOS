//
//  DefaultAuthInputValidationRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import DataSource
import Domain


import RxSwift

public class DefaultAuthInputValidationRepository: AuthInputValidationRepository {
    
    let networkService = AuthService()
    
    public init() { }
    
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Void> {
        
        networkService
            .request(api: .startPhoneNumberAuth(phoneNumber: phoneNumber), with: .plain)
            .map { _ in return () }
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Void> {
        
        networkService.request(api: .checkAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber), with: .plain)
            .map { _ in return () }
    }
    
    public func requestBusinessNumberAuthentication(businessNumber: String) -> Single<BusinessInfoVO> {
        
        networkService.requestDecodable(
            api: .authenticateBusinessNumber(businessNumber: businessNumber),
            with: .plain
        ).map { (dto: BusinessInfoDTO) in dto.toEntity() }
    }
    
    public func requestCheckingIdDuplication(id: String) -> Single<Void> {
        networkService.request(api: .checkIdDuplication(id: id), with: .plain)
            .map { _ in return () }
    }
}

