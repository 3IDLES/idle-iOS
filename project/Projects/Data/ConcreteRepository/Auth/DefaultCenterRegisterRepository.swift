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
                
                switch response.statusCode {
                case 204:
                    return .success(true)
                default:
                    return PhoneNumberAuthResult.failure(self?.decodeError(of: CenterRegisterError.self, data: response.data) ?? .unknownError())
                }
            }
        
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> RxSwift.Single<PhoneNumberAuthResult> {
        
        networkService.request(api: .checkAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber))
            .map { [weak self] response in
                
                switch response.statusCode {
                case 204:
                    return PhoneNumberAuthResult.success(true)
                default:
                    return PhoneNumberAuthResult.failure(self?.decodeError(of: CenterRegisterError.self, data: response.data) ?? .unknownError())
                }
            }
    }
}
