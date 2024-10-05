//
//  BaseViewModel.swift
//  BaseFeature
//
//  Created by choijunios on 9/4/24.
//

import Foundation
import Domain
import DSKit


import RxSwift
import RxCocoa

open class BaseViewModel {
    
    // Alert
    public let alert: PublishSubject<DefaultAlertContentVO> = .init()
    var alertDriver: Driver<DefaultAlertContentVO>?
    
    public let alertObject: PublishSubject<IdleAlertObject> = .init()
    var alertObjectDriver: Driver<IdleAlertObject>?
    
    // MARK: SnackBarStack
    private var snackBarStack: [IdleSnackBarRO] = []
    
    let viewDidAppear: PublishSubject<Void> = .init()
    
    // 로딩
    public let showLoading: PublishSubject<Void> = .init()
    public let dismissLoading: PublishSubject<Void> = .init()
    var showLoadingDriver: Driver<Void>?
    var dismissLoadingDriver: Driver<Void>?
    
    public let disposeBag = DisposeBag()
    
    public init() { 
        
        self.alertDriver = alert
            .asDriver(onErrorDriveWith: .never())
        
        self.alertObjectDriver = alertObject
            .asDriver(onErrorDriveWith: .never())
            
        self.showLoadingDriver = showLoading
            .asDriver(onErrorDriveWith: .never())
        
        self.dismissLoadingDriver = dismissLoading
            .asDriver(onErrorDriveWith: .never())
    }
    
    public func mapStartLoading<T>(_ target: Observable<T>) -> Observable<T> {
        
        target
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { [weak self] item in
                
                self?.showLoading.onNext(())
                
                return item
            }
    }
    
    public func mapEndLoading<T>(_ target: Observable<T>) -> Observable<T> {
        
        target
            .map { [weak self] item in
                
                self?.dismissLoading.onNext(())
                
                return item
            }
    }
}
