//
//  CTAButton.swift
//  PresentationCore
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift

public protocol CTAButtonEnableInputable {
    var ctaButtonClicked: Observable<UITapGestureRecognizer>? { get set }
}

public protocol CTAButtonEnableOutPutable {
    var ctaButtonEnabled: BehaviorSubject<Bool>? { get }
}
