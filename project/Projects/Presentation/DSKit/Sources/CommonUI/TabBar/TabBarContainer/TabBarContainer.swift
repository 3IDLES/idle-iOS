//
//  TabBarContainer.swift
//  DSKit
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IdleTabBarContainer: UIView {
    
    let items: [UIView]
    
    public init(items: [UIView]) {
        self.items = items
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
    }
    required init?(coder: NSCoder) { nil }
    
    func setAppearance() {
        self.backgroundColor = DSColor.gray0.color
    }
    
    func setLayout() {
        self.layoutMargins = .init(
            top: 8,
            left: 55.5,
            bottom: 8,
            right: 55.5
        )
        
        let mainStack = HStack(
            items,
            alignment: .fill,
            distribution: .equalCentering
        )
        
        let border = Spacer(height: 1)
        border.backgroundColor = DSColor.gray100.color
        
        [
            border,
            mainStack
        ].forEach {
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            
            border.topAnchor.constraint(equalTo: self.topAnchor),
            border.leftAnchor.constraint(equalTo: self.leftAnchor),
            border.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }
}
