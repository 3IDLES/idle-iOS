//
//  UseCaseBase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/9/24.
//

import Foundation


import RxSwift

public protocol BaseUseCase: AnyObject { }

public extension BaseUseCase {
    
    /// Repository로 부터 전달받은 언어레벨의 에러를 도메인 특화 에러로 변경하고, error를 Result의 Failure로, 성공을 Success로 변경합니다.
    func convert<T>(task: Single<T>) -> Single<Result<T, DomainError>> {
        Single.create { single in
            let disposable = task
                .subscribe { success in
                    single(.success(.success(success)))
                } onFailure: { error in
                    single(.success(.failure(self.toDomainError(error: error))))
                }
            return Disposables.create { disposable.dispose() }
        }
    }
    
    // MARK: InputValidationError
    private func toDomainError(error: Error) -> DomainError {
        
        // 네트워크 에러
        if let httpError = error as? HTTPResponseException {
            
            if let code = httpError.rawCode {
                
                let domainError = DomainError(code: code)
                
                if domainError == .undefinedCode {
#if DEBUG
                    print("‼️ 정의되지 않은 에러코드가 발견되었습니다. 노션을 확인해주세요")
#endif
                }
                
                return domainError
            }
            
            #if DEBUG
            print("InputValidationError변환실패 Error: \(httpError)")
            #endif
        }
        
        // 네트워크 에러보다 근본적인 에러
        if let underlyingError = error as? UnderLyingError {
            
            let domainError: DomainError = .undelyingError(error: underlyingError)
            
            return domainError
        }
         
        return DomainError.undelyingError(error: .unHandledError)
    }
}
