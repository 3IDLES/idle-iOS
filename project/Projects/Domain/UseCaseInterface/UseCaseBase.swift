//
//  UseCaseBase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/9/24.
//

import Foundation
import RxSwift
import Entity

public protocol UseCaseBase: AnyObject { }

public extension UseCaseBase {
    
    /// Repository로 부터 전달받은 언어레벨의 에러를 도메인 특화 에러로 변경하고, error를 Result의 Failure로, 성공을 Success로 변경합니다.
    func convert<T, F>(task: Single<T>, errorClosure: @escaping (Error) -> F) -> Single<Result<T, F>> {
        Single.create { single in
            let disposable = task
                .subscribe { success in
                    single(.success(.success(success)))
                } onFailure: { error in
                    single(.failure(errorClosure(error)))
                }
            return Disposables.create { disposable.dispose() }
        }
    }
    
    // MARK: InputValidationError
    func toDomainError<T: DomainError>(error: Error) -> T {

        if let httpError = error as? HTTPResponseException {
            
            if let code = httpError.rawCode {
                
                return T.init(rawValue: code) ?? T.undefinedError
            }
            
            #if DEBUG
            print("InputValidationError변환실패 Error: \(httpError)")
            #endif
        }
        
        return T.undefinedError
    }
}
