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
    
    let notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DSIcon.bell.image
        imageView.tintColor = DSColor.gray200.color
        imageView.isHidden = true
        return imageView
    }()
    
    
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
                notificationImageView
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
        
            notificationImageView.widthAnchor.constraint(equalToConstant: 32),
            notificationImageView.heightAnchor.constraint(equalTo: notificationImageView.widthAnchor),
            
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])

    }
}
