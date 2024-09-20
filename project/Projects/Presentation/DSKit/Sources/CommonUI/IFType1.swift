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
    public private(set) var placeHolderText: String
    public private(set) var submitButtonText: String
    public private(set) var keyboardType: UIKeyboardType
    
    // TextInput
    public private(set) var currentTextInout = ""
    
    // Observable
    /// 버튼을 누를시 텍스트를 반환하는 event publisher입니다.
    public let eventPublisher: PublishSubject<String> = .init()
    
    // View
    public private(set) lazy var idleTextField = IdleOneLineInputField(
        placeHolderText: placeHolderText,
        keyboardType: keyboardType
    )
    public var uITextField: UITextField { idleTextField.textField }
    public private(set) lazy var button: TextButtonType1 = {
       
        let btn = TextButtonType1(labelText: submitButtonText)
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(
        state: State = .waitForInput,
        placeHolderText: String,
        submitButtonText: String,
        keyboardType: UIKeyboardType = .default
    ) {
        self.state = .waitForInput
        self.placeHolderText = placeHolderText
        self.submitButtonText = submitButtonText
        self.keyboardType = keyboardType
        super.init(frame: .zero)
        
        setStack()
        setAutoLayout()
        setObservable()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setStack() {
        
        self.alignment = .fill
        self.axis = .horizontal
        self.spacing = 4.0
    }
    
    func setAutoLayout() {
    
        [
            idleTextField,
            button,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        idleTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        idleTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
        
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 78),
        ])
    }
    
    private func setObservable() {
        
        button
            .eventPublisher
            .map({ [weak self] _ in
                _ = self?.idleTextField.resignFirstResponder()
                return self?.idleTextField.textField.text ?? ""
            })
            .bind(to: eventPublisher)
            .disposed(by: disposeBag)
    }
    
    public override func resignFirstResponder() -> Bool {
        
        _ = idleTextField.resignFirstResponder()
        
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
