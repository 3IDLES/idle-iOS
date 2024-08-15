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
    
    var lineHeight: CGFloat {
        switch self {
        case .Heading1:
            34.8
        case .Heading2:
            28
        case .Heading3:
            24
        case .Heading4:
            22
        case .Subtitle1:
            28
        case .Subtitle2:
            24
        case .Subtitle3:
            22
        case .Subtitle4:
            20
        case .Body1:
            24
        case .Body2:
            22
        case .Body3:
            20
        case .caption:
            18.6
        case .caption2:
            18.6
        }
    }
    
    public var attributes: Attrubutes {
        
        switch self {
        case .Heading1:
            Self.createAttribute(
                weight: .Bold,
                size: 24,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Heading2:
            Self.createAttribute(
                weight: .Bold,
                size: 20,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Heading3:
            Self.createAttribute(
                weight: .Bold,
                size: 18,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Heading4:
            Self.createAttribute(
                weight: .Bold,
                size: 16,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle1:
            Self.createAttribute(
                weight: .Semibold,
                size: 20,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle2:
            Self.createAttribute(
                weight: .Semibold,
                size: 18,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle3:
            Self.createAttribute(
                weight: .Semibold,
                size: 16,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Subtitle4:
            Self.createAttribute(
                weight: .Semibold,
                size: 14,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Body1:
            Self.createAttribute(
                weight: .medium,
                size: 18,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Body2:
            Self.createAttribute(
                weight: .medium,
                size: 16,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .Body3:
            Self.createAttribute(
                weight: .medium,
                size: 14,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .caption:
            Self.createAttribute(
                weight: .medium,
                size: 12,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        case .caption2:
            Self.createAttribute(
                weight: .Semibold,
                size: 12,
                letterSpacing: -0.2,
                color: DSKitAsset.Colors.gray900.color
            )
        }
        
    }
    static func createAttribute(
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
        
        return [
            .font: font!,
            .foregroundColor: color,
            .kern: letterSpacing
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

