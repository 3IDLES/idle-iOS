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

open class BaseViewModel {
    
    // Alert
    public let alert: PublishSubject<DefaultAlertContentVO> = .init()
    var alertDriver: Driver<DefaultAlertContentVO>?
    
    // 로딩
    public let showLoading: PublishSubject<Void> = .init()
    public let dismissLoading: PublishSubject<Void> = .init()
    var showLoadingDriver: Driver<Void>?
    var dismissLoadingDriver: Driver<Void>?
    
    public let disposeBag = DisposeBag()
    
    public init() { 
        
        self.alertDriver = alert
            .asDriver(onErrorDriveWith: .never())
            
        self.showLoadingDriver = showLoading
            .asDriver(onErrorDriveWith: .never())
        
        self.dismissLoadingDriver = dismissLoading
            .asDriver(onErrorDriveWith: .never())
    }
}
