//
//  HStack.swift
//  DSKit
//
//  Created by choijunios on 7/18/24.
//

import UIKit

public class HStack: UIStackView {
    
    public init(_ elements: [UIView], spacing: CGFloat = 0.0, alignment: UIStackView.Alignment = .center, distribution: UIStackView.Distribution = .fill) {
        
        super.init(frame: .zero)
        
        self.spacing = spacing
        self.axis = .horizontal
        self.distribution = distribution
        self.alignment = alignment
        
        elements
            .forEach {
                self.addArrangedSubview($0)
            }
    }
    
    required init(coder: NSCoder) { fatalError() }
}

