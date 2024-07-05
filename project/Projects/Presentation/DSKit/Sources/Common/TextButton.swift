//
//  TextButton.swift
//  DSKit
//
//  Created by choijunios on 7/5/24.
//

import UIKit
import RxSwift
import RxCocoa

public class TextButtonType1: UIView {
    
    lazy var label: UILabel = {
       
        let view = UILabel()
        
        view.text = labelText
        view.textColor = .white
        view.font = .systemFont(ofSize: 16, weight: UIFont.Weight(700))
        view.textAlignment = .center
        
        return view
    }()
    
    public let labelText: String
    
    private var tapGesture: UITapGestureRecognizer!
    
    public var eventPublisher: Signal<UITapGestureRecognizer> { tapGesture.rx.event.asSignal() }
    
    init(labelText: String) {
        
        self.labelText = labelText
        
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
        
        let orginColor: UIColor = DSKitAsset.Colors.orange500.color
        self.backgroundColor = DSKitAsset.Colors.orange300.color
        
        UIView.animate(withDuration: 0.2) {
            
            self.backgroundColor = orginColor
            self.layer.displayIfNeeded()
        }
    }
}

extension TextButtonType1 {
    
    enum State {
        
        case active
        case inactive
    }
}
