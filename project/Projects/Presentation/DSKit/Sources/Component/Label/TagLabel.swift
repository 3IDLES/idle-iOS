//
//  TagLabel.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit

public class TagLabel: IdleLabel {
    
    public init(
        text: String,
        typography: Typography,
        textColor: UIColor,
        backgroundColor: UIColor
    ) {
        super.init(typography: typography)
        
        self.textString = text
        
        self.textAlignment = .center
        self.backgroundColor = backgroundColor
        self.attrTextColor = textColor
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    
    public override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return .init(
            width: superSize.width + 8,
            height: superSize.height + 1
        )
    }
    
    public override var textString: String {
     
        get {
            super.textString
        }
        set {
            super.textString = newValue
            invalidateIntrinsicContentSize()
        }
    }
}

