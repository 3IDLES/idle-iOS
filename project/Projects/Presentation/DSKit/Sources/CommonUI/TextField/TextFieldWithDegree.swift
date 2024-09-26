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
    }
    
    private func setLayout() {
        
        let textFieldWrapper = UIView()
        textFieldWrapper.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = HStack(
            [
                textFieldWrapper,
                degreeLabel,
            ],
            spacing: 6,
            alignment: .center,
            distribution: .fill
        )
        
        textFieldWrapper.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textFieldWrapper.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
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
            
            textFieldWrapper.heightAnchor.constraint(equalToConstant: 44),
            textField.centerYAnchor.constraint(equalTo: textFieldWrapper.centerYAnchor),
            textField.leftAnchor.constraint(equalTo: textFieldWrapper.leftAnchor),
            textField.rightAnchor.constraint(equalTo: textFieldWrapper.rightAnchor),
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
    }
}

extension TextFieldWithDegree: IdleKeyboardAvoidable { }
