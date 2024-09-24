//
//  BoardSortigHeaderView.swift
//  DSKit
//
//  Created by choijunios on 8/15/24.
//

import UIKit

public class BoardSortigHeaderView: UIView {
    
    public let sortingTypeButton: ImageTextButton = {
        let button = ImageTextButton(
            iconImage: DSKitAsset.Icons.chevronDown.image,
            position: .postfix
        )
        button.label.textString = "정렬 기준"
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        
        /// ‼️ 미구현 기능
        button.isHidden = true
        
        return button
    }()
    
    public init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setLayout() {
        
        [
            sortingTypeButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            sortingTypeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            sortingTypeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -24),
            sortingTypeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
        ])
    }
}
