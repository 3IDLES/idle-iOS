//
//  IFType1.swift
//  DSKit
//
//  Created by choijunios on 7/5/24.
//

import UIKit
import RxSwift

public class IFType1: UIStackView {
    
    private var state: State
    
    // Init parameters
    public private(set) var titleText: String
    public private(set) var placeHolderText: String
    public private(set) var submitButtonText: String
    
    // TextInput
    public private(set) var currentTextInout = ""
    
    // Observable
    public let eventPublisher: PublishSubject<String> = .init()
    
    // View
    private lazy var textField = IdleOneLineInputField(
        placeHolderText: placeHolderText,
        keyboardType: .numberPad
    )
    private lazy var button: TextButtonType1 = {
       
        let btn = TextButtonType1(labelText: submitButtonText)
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(
        state: State = .waitForInput,
        titleText: String,
        placeHolderText: String,
        submitButtonText: String
    ) {
        self.state = .waitForInput
        self.titleText = titleText
        self.placeHolderText = placeHolderText
        self.submitButtonText = submitButtonText
        super.init(frame: .zero)
        
        setStack()
        setAutoLayout()
        setObservable()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStack() {
        
        self.alignment = .top
        self.axis = .horizontal
        self.spacing = 4.0
    }
    
    func setAutoLayout() {
    
        [
            textField,
            button,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
        
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 78),
        ])
    }
    
    private func setObservable() {
        
        button
            .eventPublisher
            .emit { [weak self] _ in
                
                // 문자열 전송
                self?.eventPublisher
                    .onNext(
                        self?.textField.textField.text ?? ""
                    )
                
                _ = self?.textField.resignFirstResponder()
            }
            .disposed(by: disposeBag)
    }
    
    public override func resignFirstResponder() -> Bool {
        
        _ = textField.resignFirstResponder()
        
        return super.resignFirstResponder()
    }
}

public extension IFType1 {
    
    func setState(_ state: State) {
        
        self.state = state
        
        switch state {
        case .waitForInput, .waitForValidation:
            self.isUserInteractionEnabled = true
        case .waitForSubmit:
            self.isUserInteractionEnabled = false
        }
    }
    
    enum State {
        
        // Active
        case waitForInput
        case waitForValidation
        
        // InActive
        case waitForSubmit
        
        /// 버튼의 Activity
        var isActive: Bool {
            switch self {
            case .waitForInput, .waitForValidation:
                return false
            case .waitForSubmit:
                return true
            }
        }
    }
    
}
