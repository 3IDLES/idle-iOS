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
    
    public override var intrinsicContentSize: CGSize {
        
        let size = super.intrinsicContentSize
        
        if currentLineCount != 0 {
            return CGSize(width: size.width, height: typography.lineHeight * CGFloat(currentLineCount))
        }
        return super.intrinsicContentSize
    }
    
    public var typography: Typography {
        get {
            currentTypography
        }
        set {
            currentTypography = newValue
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
            self.invalidateIntrinsicContentSize()
        }
    }
    
    public func setAttr(attr: NSAttributedString.Key, value: Any) {
        let newAttr: [NSAttributedString.Key: Any] = [attr: value]
        currentAttributes = newAttr.merging(currentAttributes) { first, _ in first }
        updateText()
        invalidateIntrinsicContentSize()
    }
    
    private func updateText() {
        self.rx.attributedText.onNext(NSAttributedString(string: textString, attributes: currentAttributes))
        invalidateIntrinsicContentSize()
    }
}
