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
    
    func filteringDataLayer<T>(domainTask: Observable<Result<T, IdleError>>?) -> Observable<Result<T, IdleError>> {
        
        return Observable.create { observer in
            let task = domainTask?
                .subscribe { result in observer.onNext(result) } onError: { error in
                    
                    // UseCase영역에서 네트워크 오류가 발생하였음을 확인합니다.
                    
                    if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
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
}
