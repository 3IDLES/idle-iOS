//
//  StateButtonTyp1.swift
//  DSKit
//
//  Created by choijunios on 7/14/24.
//

import UIKit
import RxCocoa

public class StateButtonTyp1: UIView {
    
    // Init values
    public private(set) var state: State
    
    public var normalAppearance: StateSetting
    public var accentAppearance: StateSetting
    
    public let eventPublisher: PublishRelay<State> = .init()
    
    // View
    public let label: IdleLabel = {
        let view = IdleLabel(typography: .Body3)
        return view
    }()
    
    public init(
        text: String,
        initial: State,
        normalAppearance: StateSetting = .normalDefault,
        accentAppearance: StateSetting = .accentDefault
    ) {
        self.state = initial
        self.normalAppearance = normalAppearance
        self.accentAppearance = accentAppearance
        
        super.init(frame: .zero)
        
        label.textString = text
        
        setAppearance()
        setAutoLayout()
        setTapGesture()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
        
        applySetting(setting: self.state == .accent ? accentAppearance : normalAppearance)
    }
    
    private func setAutoLayout() {
        
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
        
        if self.state == state { return }
        
        self.state = state
        
        eventPublisher.accept(state)
        
        var setting: StateSetting!
        
        setting = state == .normal ? normalAppearance : accentAppearance
        
        UIView.animate(withDuration: withAnimation ? 0.1 : 0.0) { [unowned self] in
            applySetting(setting: setting)
        }
    }
    
    private func applySetting(setting: StateSetting) {
        self.layer.borderColor = setting.borderColor.cgColor
        self.backgroundColor = setting.backgroundColor
        
        label.typography = setting.typography
        label.attrTextColor = setting.textColor
    }
}

public extension StateButtonTyp1 {
    
    enum State {
        case normal, accent
    }
    
    struct StateSetting {
        
        public var textColor: UIColor
        public var typography: Typography
        
        public var borderColor: UIColor
        public var backgroundColor: UIColor
        
        public static var normalDefault: StateSetting {
            StateSetting(
                textColor: DSKitAsset.Colors.gray500.color,
                typography: .Body3,
                borderColor: DSKitAsset.Colors.gray100.color,
                backgroundColor: .white
            )
        }
        
        public static var accentDefault: StateSetting {
            StateSetting(
                textColor: DSKitAsset.Colors.orange500.color,
                typography: .Subtitle4,
                borderColor: DSKitAsset.Colors.orange400.color,
                backgroundColor: DSKitAsset.Colors.orange100.color
            )
        }
    }
}
