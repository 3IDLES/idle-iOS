//
//  TypograpyFamily.swift
//  DSKit
//
//  Created by choijunios on 7/14/24.
//

import UIKit

public enum Typography {
    
    public typealias Attrubutes = [NSAttributedString.Key : Any]
    
    enum FontWeight: Int {
        case Bold=700
        case Semibold=600
        case medium=500
    }
    
    case Heading1
    case Heading2
    case Heading3
    case Heading4
    
    case Subtitle1
    case Subtitle2
    case Subtitle3
    case Subtitle4
    
    case Body1
    case Body2
    case Body3
    
    case caption
    case caption2
    
    var lineHeight: CGFloat? {
        switch self {
        case .Heading1:
            36
        case .Heading2:
            32
        case .Heading3:
            30
        case .Heading4:
            26
            
            
        case .Subtitle1:
            32
        case .Subtitle2:
            30
        case .Subtitle3:
            26
        case .Subtitle4:
            22
            
            
        case .Body1:
            30
        case .Body2:
            26
        case .Body3:
            22
            
        default:
            nil
        }
    }
    
    public var attributesWithoutLineHeightInset: Attrubutes {
        var attrs = attributes
        (attrs[.paragraphStyle] as? NSMutableParagraphStyle)?.minimumLineHeight = 0
        (attrs[.paragraphStyle] as? NSMutableParagraphStyle)?.maximumLineHeight = 0
        attrs[.baselineOffset] = 0
        return attrs
    }
    
    public var attributes: Attrubutes {
        
        switch self {
        case .Heading1:
            createAttribute(
                weight: .Bold,
                size: 24,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Heading2:
            createAttribute(
                weight: .Bold,
                size: 20,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Heading3:
            createAttribute(
                weight: .Bold,
                size: 18,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Heading4:
            createAttribute(
                weight: .Bold,
                size: 16,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle1:
            createAttribute(
                weight: .Semibold,
                size: 20,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle2:
            createAttribute(
                weight: .Semibold,
                size: 18,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle3:
            createAttribute(
                weight: .Semibold,
                size: 16,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle4:
            createAttribute(
                weight: .Semibold,
                size: 14,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Body1:
            createAttribute(
                weight: .medium,
                size: 18,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Body2:
            createAttribute(
                weight: .medium,
                size: 16,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Body3:
            createAttribute(
                weight: .medium,
                size: 14,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .caption:
            createAttribute(
                weight: .medium,
                size: 12,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .caption2:
            createAttribute(
                weight: .Semibold,
                size: 12,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        }
        
    }
    func createAttribute(
        weight: FontWeight,
        size: CGFloat,
        letterSpacing: CGFloat,
        color: UIColor
    ) -> Attrubutes {
        
        var font: UIFont!
        switch weight {
        case .Bold:
            font = DSKitFontFamily.Pretendard.bold.font(size: size)
        case .Semibold:
            font = DSKitFontFamily.Pretendard.semiBold.font(size: size)
        case .medium:
            font = DSKitFontFamily.Pretendard.medium.font(size: size)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        var baseLineOffset: CGFloat = 0.0
        
        if let lineHeight {
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            baseLineOffset = (lineHeight-font.lineHeight)/2
        }
        
        return [
            .font: font!,
            .foregroundColor: color,
            .kern: letterSpacing,
            .paragraphStyle : paragraphStyle,
            .baselineOffset : baseLineOffset
        ]
    }
}

public extension Typography.Attrubutes {
    
    func toString(_ text: String) -> NSMutableAttributedString {
        .init(string: text, attributes: self)
    }
    
    func toString(_ text: String, with color: UIColor) -> NSMutableAttributedString {
        
        let merged: Typography.Attrubutes = [.foregroundColor: color].merging(self) { first, _ in first }
        
        return .init(string: text, attributes: merged)
    }
}


public extension NSMutableAttributedString {
    
    func setTextColor(to color: UIColor) {
        self.setAttributes([.foregroundColor: color], range: NSRange(location: 0, length: self.length))
    }
}

