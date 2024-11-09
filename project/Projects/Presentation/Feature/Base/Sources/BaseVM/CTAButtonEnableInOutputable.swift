//
//  Legacy.swift
//  BaseFeature
//
//  Created by choijunios on 9/4/24.
//

import UIKit
import Domain


import RxSwift
import RxCocoa


public enum PageProcessAction {
    case next
    case complete
}

public protocol PageProcessInputable {
    var nextButtonClicked: PublishSubject<Void> { get }
    var prevButtonClicked: PublishSubject<Void> { get }
    var completeButtonClicked: PublishSubject<Void> { get }
}

