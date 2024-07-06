//
//  CteateTypegraphyString.swift
//  DSKit
//
//  Created by choijunios on 7/6/24.
//

import Foundation
import UIKit

internal extension String {
    
    func applyTypegraphy(
        font: UIFont,
        lineHeight: CGFloat? = nil,
        letter: CGFloat? = nil // 자간(글자 간격, kern)
    ) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: self)
        
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attributedString.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        // 행 높이(line height) 적용
        if let lineHeight {
            
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
        }
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // 자간 설정
        if let letter {
            attributedString.addAttribute(.kern, value: letter, range: NSRange(location: 0, length: attributedString.length))
        }
        
        return attributedString
    }
}
