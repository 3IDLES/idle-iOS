//
//  DefaultCenterRegisterUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefaultCenterRegisterUseCase: CenterRegisterUseCase {

    let repository: CenterRegisterRepository
    
    public init(repository: CenterRegisterRepository) {
        self.repository = repository
    }
    
    // MARK: 전화번호 인증
    public func requestPhoneNumberAuthentication(phoneNumber: String) -> Single<PhoneNumberAuthResult> {
        
        return repository.requestPhoneNumberAuthentication(phoneNumber: phoneNumber)
    }
    
    public func checkPhoneNumberIsValid(phoneNumber: String) -> Bool {
        let regex = "^\\d{11}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: phoneNumber)
    }
    
    public func authenticateAuthNumber(phoneNumber: String, authNumber: String) -> Single<PhoneNumberAuthResult> {
        
        return repository.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
    }
    
    // MARK: 사업자 번호 인증
    public func requestBusinessNumberAuthentication(businessNumber: String) -> Observable<BusinessNumberAuthResult> {
        return Observable.create { [weak self] observer in
            let task = self?.repository.requestBusinessNumberAuthentication(businessNumber: businessNumber)
                .subscribe { result in observer.onNext(result) } onFailure: { error in
                    
                    // UseCase영역에서 네트워크 오류가 발생하였음을 확인합니다.
                    
                    if let urlError = error as? URLError, urlError.code == .networkConnectionLost {
                        // 네트워크 비연결 에러
                        observer.onNext(.failure(.networkError))
                    } else {
                        // 알수 없는 에러
                        observer.onNext(.failure(.unknownError))
                    }
                }
            return Disposables.create {
                task?.dispose()
            }
        }
    }
    
    public func checkBusinessNumberIsValid(businessNumber: String) -> Bool {
        let regex = "^\\d{10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluate(with: businessNumber)
    }
}
