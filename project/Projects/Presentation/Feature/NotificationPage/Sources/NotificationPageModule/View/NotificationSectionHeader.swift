//
//  NotificationSectionHeader.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit
import DSKit

class NotificationSectionHeader: UIView {
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        return label
    }()
    
    init(titleText: String) {
        self.titleLabel.textString = titleText
        super.init(frame: .zero)
        
        self.backgroundColor = DSColor.gray0.color
        
        setUpUI()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setUpUI() {
        
        [
            titleLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
    }
}
