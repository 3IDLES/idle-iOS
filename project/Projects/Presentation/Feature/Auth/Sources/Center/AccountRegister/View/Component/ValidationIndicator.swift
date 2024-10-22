//
//  ValidationIndicator.swift
//  AuthFeature
//
//  Created by choijunios on 10/22/24.
//

import Foundation
import UIKit

import DSKit

class ValidationIndicator: UIView {
    
    enum State {
        case valid
        case invalid
    }
    
    // Init
    let validText: String
    let invalidText: String
    
    // View
    let iconView: UIImageView = {
        let view: UIImageView = .init()
        return view
    }()
    
    let label: IdleLabel = {
        let label: IdleLabel = .init(typography: .Body3)
        return label
    }()
    
    init(validText: String, invalidText: String) {
        self.validText = validText
        self.invalidText = invalidText
        super.init(frame: .zero)
        
        setLayout()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setLayout() {
        
        let mainStack: HStack = HStack(
            [iconView, label, Spacer()],
            spacing: 4,
            alignment: .center
        )
        
        self.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    func setState(_ state: State, animated: Bool = true) {
        
        let animateDuration: TimeInterval = animated ? 0.2 : 0
        
        UIView.transition(with: self, duration: animateDuration, options: .transitionCrossDissolve) {
            self.iconView.image = state == .valid ? AuthFeatureAsset.vsMark.image : AuthFeatureAsset.vfMark.image
        }
        
        UIView.animate(withDuration: animateDuration) {
            self.label.attrTextColor = state == .valid ? DSColor.green.color : DSColor.red200.color
        
            self.label.textString = state == .valid ? self.validText : self.invalidText
        }
    }
}
