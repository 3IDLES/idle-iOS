//
//  PrevOrNextContainer.swift
//  DSKit
//
//  Created by choijunios on 9/16/24.
//

import UIKit
import RxSwift
import RxCocoa

public class PrevOrNextContainer: HStack {
    
    // View
    public let prevButton: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = "이전"
        return button
    }()
    
    public let nextButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .medium)
        button.label.textString = "다음"
        return button
    }()
    
    public lazy var nextBtnClicked: Driver<Void> = nextButton.rx.tap.asDriver()
    public lazy var prevBtnClicked: Driver<Void> = prevButton.rx.tap.asDriver()
    
    public init() {
        super.init(
            [
                prevButton,
                nextButton
            ],
            spacing: 8,
            alignment: .fill,
            distribution: .fillEqually
        )
    }
    public required init(coder: NSCoder) { fatalError() }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    PrevOrNextContainer()
}
