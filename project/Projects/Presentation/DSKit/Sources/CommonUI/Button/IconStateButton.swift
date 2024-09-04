//
//  IconStateButton.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IconWithColorStateButton: TappableUIView {
    
    // Init values
    public private(set) var state: State
    
    public lazy var onTapEvent: Observable<State> = {
        self.rx.tap.compactMap { [weak self] _ in
            self?.state
        }.asObservable()
    }()
    
    public var representImage: UIImage
    public var normalColor: UIColor
    public var accentColor: UIColor
    
    let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
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
        
        super.init()
        
        self.addSubview(imageView)
        
        setAppearance()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = .init(origin: .zero, size: self.bounds.size)
    }
    
    private func setAppearance() {
        
        self.contentMode = .scaleAspectFit
        
        // 이미지를 템플릿 모드로 변경
        let templateImage = self.representImage.withRenderingMode(.alwaysTemplate)
        self.imageView.image = templateImage
    }

    public func setState(_ state: State, withAnimation: Bool = true) {
        
        self.state = state
        
        let nextColor = state == .normal ? normalColor : accentColor
        
        // UIView.animate - 뷰 속성 변화에 적합
        // UIView.tranistion - 뷰컨텐츠변화 혹은 뷰자체에 대한 변화, 이미지의 경우 여기 해당한다.
        UIView.transition(with: self, duration: withAnimation ? 0.1 : 0.0, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.imageView.tintColor = nextColor
        }, completion: nil)
    }
    
    public func toggle() {
        
        if state == .normal {
            setState(.accent)
        } else {
            setState(.normal)
        }
    }
}

public extension IconWithColorStateButton {
    
    enum State {
        case normal, accent
    }
}
