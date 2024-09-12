//
//  BaseViewModel.swift
//  BaseFeature
//
//  Created by choijunios on 9/4/24.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import DSKit

open class BaseViewModel {
    
    // Alert
    public let alert: PublishSubject<DefaultAlertContentVO> = .init()
    var alertDriver: Driver<DefaultAlertContentVO>?
    
    public let alertObject: PublishSubject<IdleAlertObject> = .init()
    var alertObjectDriver: Driver<IdleAlertObject>?
    
    // Snack bar
    public let snackBar: PublishSubject<IdleSnackBarRO> = .init()
    var snackBarDriver: Driver<IdleSnackBarRO>?
    
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
        
        self.snackBarDriver = snackBar
            .asDriver(onErrorDriveWith: .never())
            
        self.showLoadingDriver = showLoading
            .asDriver(onErrorDriveWith: .never())
        
        self.dismissLoadingDriver = dismissLoading
            .asDriver(onErrorDriveWith: .never())
        
        // life cycle
        viewDidAppear
            .compactMap { [weak self] in
                let bars = self?.snackBarStack
                self?.snackBarStack = []
                return bars
            }
            .flatMap { bars in
                Observable
                    .from(bars)
                    .concatMap { ro in
                        Observable
                            .just(ro)
                            .delay(.milliseconds(350), scheduler: MainScheduler.instance)
                    }
            }
            .bind(to: snackBar)
            .disposed(by: disposeBag)
    }
    
    public func mapStartLoading<T>(_ target: Observable<T>) -> Observable<T> {
        
        target
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
    
    public func addSnackBar(ro: IdleSnackBarRO) {
        self.snackBarStack.append(ro)
    }
}
