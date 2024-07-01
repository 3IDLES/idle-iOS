//
//  RowButtonPrototype.swift
//  DSKit
//
//  Created by choijunios on 6/30/24.
//

import UIKit

public class ButtonPrototype: UIView {
    
    private let onTouch: () -> Void
    
    public let label = UILabel()

    public init(text: String, onTouch: @escaping () -> Void) {
        
        self.onTouch = onTouch
        
        super.init(frame: .zero)
        
        self.backgroundColor = .black
        
        label.text = text
        label.textColor = .white
        
        [
            label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        self.layoutMargins = .init(top: 10, left: 0, bottom: 10, right: 0)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchAction))
        
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func onTouchAction(_ TapGesture: UITapGestureRecognizer) {
        onTouch()
        
        let orginColor: UIColor = .black
        self.backgroundColor = .gray
        
        UIView.animate(withDuration: 0.3) {
            
            self.backgroundColor = orginColor
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
