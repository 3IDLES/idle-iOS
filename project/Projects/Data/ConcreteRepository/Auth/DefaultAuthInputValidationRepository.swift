//
//  DefaultAuthInputValidationRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxSwift
import RepositoryInterface
import NetworkDataSource
import Entity

public class DefaultAuthInputValidationRepository: AuthInputValidationRepository {
    
    let networkService = AuthService()
    
    public init() { }
    
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> RxSwift.Single<BoolResult> {
        
        networkService.requestWithoutToken(api: .startPhoneNumberAuth(phoneNumber: phoneNumber))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BoolResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 204:
                    return .success(true)
                default:
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> RxSwift.Single<BoolResult> {
        
        networkService.requestWithoutToken(api: .checkAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BoolResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 204:
                    return .success(true)
                default:
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
    
    public func requestBusinessNumberAuthentication(businessNumber: String) -> RxSwift.Single<BusinessNumberAuthResult> {
        
        networkService.requestWithoutToken(api: .authenticateBusinessNumber(businessNumber: businessNumber))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BusinessNumberAuthResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 200:
                    let dto: BusinessInfoDTO = self.decodeData(data: response.data)
                    return .success(dto.toEntity())
                default:
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
    
    public func requestCheckingIdDuplication(id: String) -> RxSwift.Single<Entity.BoolResult> {
        networkService.requestWithoutToken(api: .checkIdDuplication(id: id))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BoolResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 204:
                    return .success(true)
                case 400:
                    return .success(false)
                default:
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
}

