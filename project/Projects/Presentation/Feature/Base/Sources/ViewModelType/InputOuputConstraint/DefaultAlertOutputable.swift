//
//  DefaultAlertOutputable.swift
//  BaseFeature
//
//  Created by choijunios on 7/25/24.
//

import Entity
import RxCocoa

public protocol DefaultAlertOutputable {
    
    var alert: Driver<DefaultAlertContentVO> { get }
}
