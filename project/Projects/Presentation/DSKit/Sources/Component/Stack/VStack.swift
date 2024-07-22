//
//  VStack.swift
//  DSKit
//
//  Created by choijunios on 7/15/24.
//

import UIKit


public class VStack: UIStackView {
    
    public init(_ elements: [UIView], spacing: CGFloat = 0.0, alignment: UIStackView.Alignment = .center, distribution: UIStackView.Distribution = .fill) {
        
        super.init(frame: .zero)
        
        self.spacing = spacing
        self.axis = .vertical
        self.distribution = distribution
        self.alignment = alignment
        
        elements
            .forEach {
                self.addArrangedSubview($0)
            }
    }
    
    required init(coder: NSCoder) { fatalError() }
}

