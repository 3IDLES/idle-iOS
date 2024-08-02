//
//  CalendarOpenButton.swift
//  DSKit
//
//  Created by choijunios on 8/2/24.
//

import UIKit
import RxCocoa

public class CalendarOpenButton: TextImageButtonType2 {
    
    public override init() {
        super.init()
        textLabel.textString = "날짜를 선택해주세요."
        textLabel.attrTextColor = DSKitAsset.Colors.gray200.color
        imageView.image = DSKitAsset.Icons.calander.image
        imageView.tintColor = DSKitAsset.Colors.gray200.color
    }
    required init?(coder: NSCoder) { fatalError() }
}
