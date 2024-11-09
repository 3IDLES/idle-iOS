//
//  ObservableType+Extension.swift
//  Core
//
//  Created by choijunios on 10/1/24.
//

import Foundation


import RxSwift

public extension ObservableType {
    
    func unretained<T: AnyObject>(_ object: T) -> Observable<(T, Element)> {
        
        self
            .compactMap { [weak object] output -> (T, Element)? in
            
                guard let object else { return nil }
            
                return (object, output)
            }
            .asObservable()
    }
    
    func mapToVoid() -> Observable<Void> {
        
        self.map { _ in () }
    }
}

public extension ObservableType where Element == Bool {
    
    func onSuccess() -> Observable<Void> {
        
        self
            .filter { $0 }
            .mapToVoid()
    }
    
    func onSuccess<T>(transform: @escaping () throws -> T) -> Observable<T> {
        
        self
            .filter { $0 }
            .mapToVoid()
            .map(transform)
            .asObservable()
    }
    
    func onSuccess(onNext: @escaping () -> Void) -> Disposable {
        
        self
            .filter { $0 }
            .mapToVoid()
            .subscribe(onNext: onNext)
    }
    
    func onFailure() -> Observable<Void> {
        
        self
            .filter { !$0 }
            .mapToVoid()
    }
    
    func onFailure<T>(transform: @escaping () throws -> T) -> Observable<T> {
        
        self
            .filter { !$0 }
            .mapToVoid()
            .map(transform)
            .asObservable()
    }
    
    func onFailure(onNext: @escaping () -> Void) -> Disposable {
        
        self
            .filter { !$0 }
            .mapToVoid()
            .subscribe(onNext: onNext)
    }
}
