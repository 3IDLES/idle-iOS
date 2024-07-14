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
    private var currentText: String = ""
    
    public init(typography: Typography) {
        
        self.currentTypography = typography
        
        super.init(frame: .zero)
        
        updateText()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override var intrinsicContentSize: CGSize {
        
        let size = super.intrinsicContentSize
        
        return CGSize(width: size.width, height: typography.lineHeight)
    }
    
    var typography: Typography {
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
    
    public var attTextColor: UIColor {
        get {
            return .black
        }
        set {
            setAttr(attr: .foregroundColor, value: newValue)
        }
    }
    
    private func setAttr(attr: NSAttributedString.Key, value: Any) {
        let newAttr: [NSAttributedString.Key: Any] = [attr: value]
        let newAttrs = newAttr.merging(typography.attributes) { first, _ in first }
        
        self.rx.attributedText.onNext(NSAttributedString(string: textString, attributes: newAttrs))
        invalidateIntrinsicContentSize()
    }
    
    private func updateText() {
        self.rx.attributedText.onNext(NSAttributedString(string: textString, attributes: typography.attributes))
        invalidateIntrinsicContentSize()
    }
}
