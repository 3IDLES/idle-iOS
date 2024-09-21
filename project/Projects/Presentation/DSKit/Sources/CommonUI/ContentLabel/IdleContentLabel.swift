//
//  IdleContentLabel.swift
//  DSKit
//
//  Created by choijunios on 8/3/24.
//

import UIKit

public class IdleContentTitleLabel: UIStackView {
    
    // Init
    let titleText: String
    let subTitleText: String?
    
    // View
    public let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    public let subTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    
    public init(titleText: String, subTitleText: String? = nil) {
        self.titleText = titleText
        self.subTitleText = subTitleText
        
        super.init(frame: .zero)
        
        titleLabel.textString = titleText
        subTitleLabel.textString = subTitleText ?? ""
        
        setLayout()
    }
    public required init(coder: NSCoder) { fatalError() }
    
    private func setLayout() {
        
        self.axis = .horizontal
        self.alignment = .center
        self.spacing = 4
        
        [
            titleLabel,
            subTitleLabel,
            UIView()
        ].forEach { label in
            
            self.addArrangedSubview(label)
        }
    }
}
