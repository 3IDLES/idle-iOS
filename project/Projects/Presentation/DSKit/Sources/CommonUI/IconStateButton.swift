//
//  IconStateButton.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxCocoa

public class IconWithColorStateButton: UIImageView {
    
    // Init values
    public private(set) var state: State
    
    public var representImage: UIImage
    public var normalColor: UIColor
    public var accentColor: UIColor
    
    public let eventPublisher: PublishRelay<State> = .init()
    
    public init(
        representImage: UIImage,
        normalColor: UIColor,
        accentColor: UIColor,
        initial: State = .normal)
    {
        self.state = initial
        self.representImage = representImage
        self.normalColor = normalColor
        self.accentColor = accentColor
        
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = true
        
        setAppearance()
        setTapGesture()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
        self.contentMode = .scaleAspectFit
        
        // 이미지를 템플릿 모드로 변경
        let templateImage = self.representImage.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        
        setState(.normal)
    }
    
    private func setTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapGestureHandler() {
        switch state {
        case .normal:
            setState(.accent)
        case .accent:
            setState(.normal)
        }
    }
    
    public func setState(_ state: State, withAnimation: Bool = true) {
        
        self.state = state
        
        eventPublisher.accept(state)
        
        let nextColor = state == .normal ? normalColor : accentColor
        
        // UIView.animate - 뷰 속성 변화에 적합
        // UIView.tranistion - 뷰컨텐츠변화 혹은 뷰자체에 대한 변화, 이미지의 경우 여기 해당한다.
        UIView.transition(with: self, duration: withAnimation ? 0.1 : 0.0, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.tintColor = nextColor
        }, completion: nil)
    }
}

public extension IconWithColorStateButton {
    
    enum State {
        case normal, accent
    }
}
