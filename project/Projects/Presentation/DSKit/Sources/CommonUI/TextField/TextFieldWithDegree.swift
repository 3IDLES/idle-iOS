//
//  TextFieldWithDegree.swift
//  DSKit
//
//  Created by choijunios on 7/31/24.
//

import UIKit
import RxCocoa
import RxSwift
import PresentationCore

public class TextFieldWithDegree: UIView {
        
    // Init
    public let degreeText: String
    public let initialText: String
    
    public lazy var edtingText: Driver<String> = {
        textField.rx.text
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "")
    }()
    
    // View
    public lazy var degreeLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textString = degreeText
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .right
        return label
    }()
    public lazy var textField: IdleTextField = {
        let field = IdleTextField(typography: .Body2)
        field.textFieldInsets = .zero
        field.textString = initialText
        return field
    }()
    
    public override var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    // 키보드 어보이던스가 적용될 뷰입니다.
    public let disposeBag = DisposeBag()
    public weak var movingView: UIView?
    public var prevRect: CGRect = .zero
    public var isPushed: Bool = false
    
    public init(degreeText: String, initialText: String) {
        self.degreeText = degreeText
        self.initialText = initialText
        
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6.0
        self.layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    private func setLayout() {
        
        let stack = HStack(
            [
                textField,
                degreeLabel
            ],
            distribution: .fill
        )
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        degreeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        degreeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        [
            stack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
        
    }
}

extension TextFieldWithDegree: IdleKeyboardAvoidable { }
