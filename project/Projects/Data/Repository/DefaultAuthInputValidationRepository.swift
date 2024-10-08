//
//  DefaultAuthInputValidationRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import DataSource
import Domain
import Core


import RxSwift

public class DefaultAuthInputValidationRepository: AuthInputValidationRepository {
    
    let networkService = AuthService()
    
    public init() { }
    
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<Result<Void, DomainError>> {
        
        let dataTask = networkService
            .request(api: .startPhoneNumberAuth(phoneNumber: phoneNumber), with: .plain)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<Result<Void, DomainError>> {
        
        let dataTask = networkService.request(api: .checkAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber), with: .plain)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
    
    public func requestBusinessNumberAuthentication(businessNumber: String) -> Single<Result<BusinessInfoVO, DomainError>> {
        
        let dataTask = networkService.requestDecodable(
            api: .authenticateBusinessNumber(businessNumber: businessNumber),
            with: .plain
        ).map { (dto: BusinessInfoDTO) in dto.toEntity() }
        
        return convertToDomain(task: dataTask)
    }
    
    public func requestCheckingIdDuplication(id: String) -> Single<Result<Void, DomainError>> {
        
        let dataTask = networkService
            .request(api: .checkIdDuplication(id: id), with: .plain)
            .mapToVoid()
        
        return convertToDomain(task: dataTask)
    }
}

