//
//  TextButtonType2.swift
//  DSKit
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift
import RxCocoa

/// - 텍스트의 배치가 자유롭다.
/// - 텍스트 필드처럼 볼더를 가진다.

public class TextButtonType2: UIView {
    
    public private(set) var isEnabled: Bool = true
    
    private let textOriginColor: UIColor
    
    public private(set) lazy var label: IdleLabel = {
       
        let label = IdleLabel(typography: .Body3)
        
        label.textString = labelText
        label.attrTextColor = textOriginColor
        label.textAlignment = .left
        
        return label
    }()
    
    // Init values
    public let labelText: String
    
    private var tapGesture: UITapGestureRecognizer!
    
    public var eventPublisher: Observable<Void> { tapGesture.rx.event.map { _ in () } }
    
    public init(
        labelText: String,
        textOriginColor: UIColor = DSKitAsset.Colors.gray200.color
    ) {
        
        self.labelText = labelText
        self.textOriginColor = textOriginColor
        
        super.init(frame: .zero)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchAction))
        self.addGestureRecognizer(tapGesture)
        
        setApearance()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 1
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        
        self.layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 24)
    }
    
    func setAutoLayout() {
        
        [
            label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    @objc
    func onTouchAction(_ tapGesture: UITapGestureRecognizer) {
        
        self.alpha = 0.5
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
    }
}

// MARK: 활성상태
extension TextButtonType2: DisablableComponent {
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isUserInteractionEnabled = isEnabled
        self.backgroundColor = isEnabled ? textOriginColor : DSKitAsset.Colors.gray200.color
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    TextButtonType2(labelText: "Hello world")
}
