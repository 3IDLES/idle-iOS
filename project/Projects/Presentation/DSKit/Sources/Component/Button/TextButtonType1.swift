//
//  TextButtonType1.swift
//  DSKit
//
//  Created by choijunios on 7/5/24.
//

import UIKit
import RxSwift
import RxCocoa

public class TextButtonType1: UIView {
    
    public private(set) var isEnabled: Bool = true
    
    private let textOriginColor: UIColor
    
    lazy var label: ResizableUILabel = {
       
        let view = ResizableUILabel()
        
        view.text = labelText
        view.textColor = .white
        view.font = .systemFont(ofSize: 16, weight: UIFont.Weight(700))
        view.textAlignment = .center
        
        return view
    }()
    
    public let labelText: String
    
    private var tapGesture: UITapGestureRecognizer!
    
    public var eventPublisher: Signal<UITapGestureRecognizer> { tapGesture.rx.event.asSignal() }
    
    public init(
        labelText: String,
        textOriginColor: UIColor = DSKitAsset.Colors.orange500.color
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
        
        self.backgroundColor = DSKitAsset.Colors.orange500.color
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
        
        self.backgroundColor = DSKitAsset.Colors.orange300.color
        
        UIView.animate(withDuration: 0.3) {
            
            self.backgroundColor = self.textOriginColor
            self.layer.displayIfNeeded()
        }
    }
}

// MARK: 활성상태
extension TextButtonType1: DisablableComponent {
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isUserInteractionEnabled = isEnabled
        self.backgroundColor = isEnabled ? textOriginColor : DSKitAsset.Colors.gray200.color
    }
}
