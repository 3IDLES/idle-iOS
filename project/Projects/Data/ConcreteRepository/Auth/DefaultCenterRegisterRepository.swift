//
//  DefaultCenterRegisterRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RxSwift
import RepositoryInterface
import NetworkDataSource
import Entity

public class DefaultCenterRegisterRepository: CenterRegisterRepository {
    
    let networkService = CenterRegisterService()
    
    let disposeBag = DisposeBag()
    
    public init() { }
    
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> RxSwift.Single<BoolResult> {
        
        networkService.request(api: .startPhoneNumberAuth(phoneNumber: phoneNumber))
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
        
        networkService.request(api: .checkAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber))
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
        
        networkService.request(api: .authenticateBusinessNumber(businessNumber: businessNumber))
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
        networkService.request(api: .checkIdDuplication(id: id))
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
    
    public func requestRegisterCenterAccount(managerName: String, phoneNumber: String, businessNumber: String, id: String, password: String) -> RxSwift.Single<Entity.BoolResult> {
        
        let dto = CenterRegistrationDTO(
            identifier: id,
            password: password,
            phoneNumber: phoneNumber,
            managerName: managerName,
            centerBusinessRegistrationNumber: businessNumber
        )
        
        let data = (try? JSONEncoder().encode(dto)) ?? Data()
        
        return networkService.request(api: .registerCenterAccount(data: data))
            .catch { [weak self] in .error(self?.filterNetworkConnection($0) ?? $0) }
            .map { [weak self] response in
                
                guard let self = self else { return BoolResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 201:
                    return .success(true)
                default:
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
}

