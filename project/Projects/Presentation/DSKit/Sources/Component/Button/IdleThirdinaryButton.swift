//
//  IdleThirdinaryButton.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa

public enum IdleThirdinaryButtonLevel {
    
    case medium
    
    var buttonHeight: CGFloat {
        switch self {
        case .medium:
            56
        }
    }
    
    var typography: Typography {
        switch self {
        case .medium:
            .Heading4
        }
    }
    //textColor
    var idleTextColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.gray300.color
        }
    }
    
    var accentTextColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.gray300.color
        }
    }
    
    var disabledTextColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.gray300.color
        }
    }
    
    //background
    var idleBackgroundColor: UIColor {
        switch self {
        case .medium:
            .white
        }
    }
    
    var accentBackgroundColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.orange100.color
        }
    }
    
    var disabledBackgroundColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.gray050.color
        }
    }
    
    //border
    var idleBorderColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.orange400.color
        }
    }
    
    var accentBorderColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.orange300.color
        }
    }
    
    var disabledBorderColor: UIColor {
        switch self {
        case .medium:
            DSKitAsset.Colors.gray200.color
        }
    }
}

public class IdleThirdinaryButton: TappableUIView {
    
    // State
    public private(set) var isEnabled: Bool = true
    
    // Init
    public let level: IdleSecondaryButtonLevel
    
    // View
    public private(set) lazy var label: IdleLabel = {
        
        let label = IdleLabel(typography: level.typography)
        label.attrTextColor = .white
        return label
    }()
    
    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: level.buttonHeight)
    }
    
    private let disposeBag = DisposeBag()
    
    public init(
        level: IdleSecondaryButtonLevel
    ) {
        
        self.level = level
        super.init()
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setApearance() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        
        // InitialSetting
        backgroundColor = level.idleBackgroundColor
        label.attrTextColor = level.idleTextColor
        layer.borderColor = level.idleBorderColor.cgColor
    }
    
    private func setAutoLayout() {
        
        [
            label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
    
    private func setObservable() {
        
        self.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                
                setToAccent()
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self else { return }
                    
                    setToIdle()
                }
            }
            .disposed(by: disposeBag)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isUserInteractionEnabled = isEnabled
        
        if isEnabled {
            setToIdle()
        }
        else {
            setToDisabled()
        }
    }
    
    private func setToIdle() {
        backgroundColor = level.idleBackgroundColor
        label.attrTextColor = level.idleTextColor
        layer.borderColor = level.idleBorderColor.cgColor
    }
    
    private func setToAccent() {
        backgroundColor = level.accentBackgroundColor
        label.attrTextColor = level.accentTextColor
        layer.borderColor = level.accentBorderColor.cgColor
    }
    
    private func setToDisabled() {
        backgroundColor = level.disabledBackgroundColor
        label.attrTextColor = level.disabledTextColor
        layer.borderColor = level.disabledBorderColor.cgColor
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    let button = IdleSecondaryButton(level: .medium)
    button.label.textString = "다음"
    button.setEnabled(false)
    return button
}

