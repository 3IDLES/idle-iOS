//
//  IdleLabel.swift
//  DSKit
//
//  Created by choijunios on 7/14/24.
//

import UIKit
import RxCocoa

public class IdleLabel: UILabel {
    
    private var currentTypography: Typography
    private var currentAttributes: Typography.Attrubutes
    private var currentTextColor: UIColor = DSKitAsset.Colors.gray900.color
    private var currentText: String = ""
    private var currentLineCount: Int = 1
    
    public init(typography: Typography) {
        
        self.currentTypography = typography
        self.currentAttributes = currentTypography.attributes
        
        super.init(frame: .zero)
        
        updateText()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public var typography: Typography {
        get {
            currentTypography
        }
        set {
            currentTypography = newValue
            currentAttributes = currentTypography.attributes
            updateText()
        }
    }
    
    public var textString: String {
        get {
            return currentText
        }
        set {
            currentText = newValue
            updateText()
        }
    }
    
    public override var textAlignment: NSTextAlignment {
        get {
            super.textAlignment
        }
        set {
            
            let paragraphStyle = currentAttributes[.paragraphStyle] as! NSMutableParagraphStyle
            paragraphStyle.alignment = newValue
            super.textAlignment = newValue
            
            updateText()
        }
    }
    
    public var attrTextColor: UIColor {
        get {
            currentTextColor
        }
        set {
            currentTextColor = newValue
            setAttr(attr: .foregroundColor, value: newValue)
        }
    }
    
    public override var numberOfLines: Int {
        get {
            super.numberOfLines
        }
        set {
            super.numberOfLines = newValue
            currentLineCount = newValue
        }
    }
    
    public func setAttr(attr: NSAttributedString.Key, value: Any) {
        let newAttr: [NSAttributedString.Key: Any] = [attr: value]
        currentAttributes = newAttr.merging(currentAttributes) { first, _ in first }
        updateText()
    }
    
    private func updateText() {
        let attributedStr = NSMutableAttributedString(string: currentText, attributes: currentAttributes)
        
        self.attributedText = attributedStr
        self.sizeToFit()
    }
}
