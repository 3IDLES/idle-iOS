//
//  StickDivider.swift
//  DSKit
//
//  Created by choijunios on 7/22/24.
//

import UIKit

public class StickDivider: UIView {
    
    let dividerWidth: CGFloat
    let leftPadding: CGFloat
    let rightPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    
    // View
    private let stick: UIView = {
        let view = UIView()
        return view
    }()
    
    public override var backgroundColor: UIColor? {
        get {
            stick.backgroundColor
        }
        set {
            stick.backgroundColor = newValue
        }
    }
    
    public init(
        dividerWidth: CGFloat,
        leftPadding: CGFloat = 0.0,
        rightPadding: CGFloat = 0.0,
        topPadding: CGFloat = 0.0,
        bottomPadding: CGFloat = 0.0
    )
    {
        self.dividerWidth = dividerWidth
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        super.init(frame: .zero)
        
        setAppearance()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setAppearance() {
        super.backgroundColor = .clear
    }
    
    func setAutoLayout() {
        
        [
            stick
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(stick)
        }
        
        NSLayoutConstraint.activate([
            
            stick.widthAnchor.constraint(equalToConstant: dividerWidth),
            
            stick.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding),
            stick.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomPadding),
            stick.leftAnchor.constraint(equalTo: self.leftAnchor, constant: leftPadding),
            stick.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -rightPadding),
        ])
    }
}
