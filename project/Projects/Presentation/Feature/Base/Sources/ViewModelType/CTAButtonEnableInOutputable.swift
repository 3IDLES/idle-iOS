//
//  Legacy.swift
//  BaseFeature
//
//  Created by choijunios on 9/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public protocol RegisterValidationOutputable {
    var registerValidation: Driver<Void>? { get }
}

public enum CTAButtonAction {
    case next
    case complete
}

public protocol CTAButtonEnableInputable {
    var ctaButtonClicked: PublishRelay<Void> { get set }
}

public protocol CTAButtonEnableOutPutable {
    var ctaButtonEnabled: Driver<Bool>? { get }
}
