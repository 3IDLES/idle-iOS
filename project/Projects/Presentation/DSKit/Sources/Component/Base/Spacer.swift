//
//  Spacer.swift
//  DSKit
//
//  Created by choijunios on 8/7/24.
//

import UIKit

public class Spacer: UIView {
    
    let width: CGFloat?
    let height: CGFloat?
    
    public override var intrinsicContentSize: CGSize {
        .init(
            width: width ?? super.intrinsicContentSize.width,
            height: height ?? super.intrinsicContentSize.height
        )
    }
    
    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError() }
}
