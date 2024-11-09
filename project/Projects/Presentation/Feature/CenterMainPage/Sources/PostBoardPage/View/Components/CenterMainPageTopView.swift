//
//  CenterMainPageTopView.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/15/24.
//

import UIKit
import DSKit

class CenterMainPageTopView: UIView {
    
    lazy var titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .left
        return label
    }()
    
    let notificationBellView: NotificationBellView = .init()
    
    init() {
        super.init(frame: .zero)
        
        setAutoLayout()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setAutoLayout() {
        
        self.layoutMargins = .init(
            top: 20,
            left: 20,
            bottom: 7,
            right: 20
        )
        
        let mainStack = HStack(
            [
                titleLabel,
                Spacer(),
                notificationBellView
            ],
            alignment: .center,
            distribution: .fill
        )
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])

    }
}
