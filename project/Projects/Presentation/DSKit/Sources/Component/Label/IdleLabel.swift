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
    
    var wholeRangeParagraphStyle: NSMutableParagraphStyle? {
        
        if let text = attributedText?.string, text.isEmpty {
            return nil
        }
        
        var paragraph: NSMutableParagraphStyle
        
        if let prevParagraph = self.attributedText?.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
            paragraph = prevParagraph
        } else {
            paragraph = NSMutableParagraphStyle()
        }
        
        return paragraph
    }
    
    public override var textAlignment: NSTextAlignment {
        get {
            super.textAlignment
        }
        set {
            
            if let paragraphStyle = wholeRangeParagraphStyle {
                paragraphStyle.alignment = newValue

                self.attributedText = NSAttributedString(string: textString, attributes: [.paragraphStyle: paragraphStyle])
            }
            
            super.textAlignment = newValue
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
        invalidateIntrinsicContentSize()
    }
    
    private func updateText() {
        let attributedStr = NSMutableAttributedString(string: textString, attributes: currentAttributes)
        
        if let fontHeight = (currentTypography.attributes[.font] as? UIFont)?.lineHeight {
            
            if let paragraphStyle = wholeRangeParagraphStyle {
                    
                paragraphStyle.lineSpacing = currentTypography.lineHeight-fontHeight
                
                attributedStr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedStr.length))
            }
        }
        
        self.rx.attributedText.onNext(attributedStr)
        invalidateIntrinsicContentSize()
    }
}
