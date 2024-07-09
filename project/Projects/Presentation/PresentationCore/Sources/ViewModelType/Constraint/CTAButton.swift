//
//  CTAButton.swift
//  PresentationCore
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift

public enum CTAButtonAction {
    case next
    case complete
}

public protocol CTAButtonEnableInputable {
    var ctaButtonClicked: Observable<CTAButtonAction>? { get set }
}

public protocol CTAButtonEnableOutPutable {
    var ctaButtonEnabled: BehaviorSubject<Bool>? { get }
}
