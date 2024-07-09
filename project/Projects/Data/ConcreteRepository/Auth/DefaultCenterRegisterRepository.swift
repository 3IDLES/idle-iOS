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
    
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> RxSwift.Single<PhoneNumberAuthResult> {
        
        networkService.request(api: .startPhoneNumberAuth(phoneNumber: phoneNumber))
            .map { [weak self] response in
                
                guard let self = self else { return PhoneNumberAuthResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 204:
                    return .success(true)
                default:
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> RxSwift.Single<PhoneNumberAuthResult> {
        
        networkService.request(api: .checkAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber))
            .map { [weak self] response in
                
                guard let self = self else { return PhoneNumberAuthResult.failure(.unknownError) }
                
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
            .map { [weak self] response in
                
                guard let self = self else { return BusinessNumberAuthResult.failure(.unknownError) }
                
                switch response.statusCode {
                case 200:
                    let dto: BusinessInfoDTO = self.decodeData(data: response.data)
                    return .success(dto.toEntity())
                default:
                    print(String(data: response.data, encoding: .utf8)!)
                    return .failure(self.decodeError(of: CenterRegisterError.self, data: response.data))
                }
            }
    }
}
