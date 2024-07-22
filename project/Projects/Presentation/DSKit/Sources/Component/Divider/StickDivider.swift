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
        leftPadding: CGFloat,
        rightPadding: CGFloat)
    {
        self.dividerWidth = dividerWidth
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
        
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
            
            stick.topAnchor.constraint(equalTo: self.topAnchor),
            stick.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stick.leftAnchor.constraint(equalTo: self.leftAnchor, constant: leftPadding),
            stick.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -rightPadding),
        ])
    }
}
