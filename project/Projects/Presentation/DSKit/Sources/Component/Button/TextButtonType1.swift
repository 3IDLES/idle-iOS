//
//  TextButtonType1.swift
//  DSKit
//
//  Created by choijunios on 7/5/24.
//

import UIKit
import RxSwift
import RxCocoa

/// - 텍스트가 중앙에 배치된다.

public class TextButtonType1: UIView {
    
    public private(set) var isEnabled: Bool = true
    
    private let originBackground: UIColor
    private let accentBackground: UIColor
    
    lazy var label: IdleLabel = {
       
        let label = IdleLabel(typography: .Subtitle4)
        
        label.textString = labelText
        label.attrTextColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    public let labelText: String
    
    private var tapGesture: UITapGestureRecognizer!
    
    public var eventPublisher: Observable<UITapGestureRecognizer> { tapGesture.rx.event.asObservable() }
    
    public init(
        labelText: String,
        originBackground: UIColor = DSKitAsset.Colors.orange500.color,
        accentBackgroundColor: UIColor = DSKitAsset.Colors.orange300.color
    ) {
        
        self.labelText = labelText
        self.originBackground = originBackground
        self.accentBackground = accentBackgroundColor
        
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = originBackground
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchAction))
        self.addGestureRecognizer(tapGesture)
        
        setApearance()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        self.layer.cornerRadius = 6
    }
    
    func setAutoLayout() {
        
        [
            label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    @objc
    func onTouchAction(_ tapGesture: UITapGestureRecognizer) {
        
        self.backgroundColor = accentBackground
        
        UIView.animate(withDuration: 0.3) {
            
            self.backgroundColor = self.originBackground
            self.layer.displayIfNeeded()
        }
    }
}

// MARK: 활성상태
extension TextButtonType1: DisablableComponent {
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isUserInteractionEnabled = isEnabled
        self.backgroundColor = isEnabled ? originBackground : DSKitAsset.Colors.gray200.color
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    TextButtonType1(labelText: "Hello world")
}
