//
//  TextButtonType3.swift
//  DSKit
//
//  Created by choijunios on 7/16/24.
//

import UIKit
import RxSwift
import RxCocoa

/// 라벨 버튼

public class TextButtonType3: IdleLabel {
    
    private var tapGesture: UITapGestureRecognizer!
    
    public var eventPublisher: Observable<Void> { tapGesture.rx.event.map { _ in () } }
    
    public override init(typography: Typography) {
        
        super.init(typography: typography)
        
        self.isUserInteractionEnabled = true
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTouchAction))
        self.addGestureRecognizer(tapGesture)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    @objc
    func onTouchAction(_ tapGesture: UITapGestureRecognizer) {
        
        self.alpha = 0.5
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
    }
}
