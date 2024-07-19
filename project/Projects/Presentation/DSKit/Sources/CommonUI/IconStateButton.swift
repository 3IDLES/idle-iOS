//
//  IconStateButton.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxCocoa

public class IconStateButton: UIImageView {
    
    // Init values
    public private(set) var state: State
    
    public var normalImage: UIImage
    public var accentImage: UIImage
    
    public let eventPublisher: PublishRelay<State> = .init()
    
    // View
    let label: IdleLabel = {
       
        let view = IdleLabel(typography: .Body3)
        
        return view
    }()
    
    public init(
        normal: UIImage,
        accent: UIImage,
        initial: State) 
    {
        self.state = initial
        self.normalImage = normal
        self.accentImage = accent
        
        super.init(frame: .zero)
        
        self.isUserInteractionEnabled = true
        
        setAppearance()
        setTapGesture()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
        self.contentMode = .scaleAspectFit
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
        
        let nextImage = state == .normal ? normalImage : accentImage
        
        // UIView.animate - 뷰 속성 변화에 적합
        // UIView.tranistion - 뷰컨텐츠변화 혹은 뷰자체에 대한 변화, 이미지의 경우 여기 해당한다.
        UIView.transition(with: self, duration: withAnimation ? 0.1 : 0.0, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.image = nextImage
        }, completion: nil)
    }
}

public extension IconStateButton {
    
    enum State {
        case normal, accent
    }
}
