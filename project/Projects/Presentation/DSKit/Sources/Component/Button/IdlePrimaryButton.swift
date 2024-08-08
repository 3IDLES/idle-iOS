//
//  IdlePrimaryButton.swift
//  DSKit
//
//  Created by choijunios on 8/8/24.
//

import UIKit
import RxSwift
import RxCocoa

public enum PrimaryButtonLevel {
    case large
    case medium
    case small
    
    var buttonHeight: CGFloat {
        switch self {
        case .large:
            56
        case .medium:
            56
        case .small:
            44
        }
    }
    
    var typography: Typography {
        switch self {
        case .large:
            .Heading4
        case .medium:
            .Heading4
        case .small:
            .Subtitle4
        }
    }
}

public class IdlePrimaryButton: TappableUIView {
    
    // State
    public private(set) var isEnabled: Bool = true
    
    // Init
    public let level: PrimaryButtonLevel
    
    // View
    public private(set) lazy var label: IdleLabel = {
        
        let label = IdleLabel(typography: level.typography)
        label.attrTextColor = .white
        return label
    }()
    
    // Button config
    private let idle_background_color: UIColor = DSKitAsset.Colors.orange500.color
    private let accent_background_color: UIColor = DSKitAsset.Colors.orange300.color
    private let disabled_background_color: UIColor = DSKitAsset.Colors.gray200.color
    
    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: level.buttonHeight)
    }
    
    private let disposeBag = DisposeBag()
    
    public init(
        level: PrimaryButtonLevel
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
        
        // InitialSetting
        backgroundColor = idle_background_color
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
                
                backgroundColor = accent_background_color
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.backgroundColor = self?.idle_background_color
                }
            }
            .disposed(by: disposeBag)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isUserInteractionEnabled = isEnabled
        self.backgroundColor = isEnabled ? idle_background_color : disabled_background_color
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    let button = IdlePrimaryButton(level: .large)
    button.label.textString = "다음"
    
    return button
}
