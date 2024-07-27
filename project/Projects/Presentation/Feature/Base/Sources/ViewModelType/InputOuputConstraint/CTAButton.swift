//
//  CTAButton.swift
//  BaseFeature
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa

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
