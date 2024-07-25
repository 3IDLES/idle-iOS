//
//  RegisterSuccessOutputable.swift
//  PresentationCore
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import RxCocoa
import Entity

public protocol RegisterValidationOutputable {
    var registerValidation: Driver<Void>? { get }
    var alert: Driver<DefaultAlertContentVO>? { get }
}
