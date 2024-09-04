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
    public var alert: Driver<DefaultAlertContentVO>?
    
    // 로딩
    public var showLoading: Driver<Void>?
    public var dismissLoading: Driver<Void>?
    
    public init() { }
}
