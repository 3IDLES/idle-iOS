//
//  IFType2.swift
//  DSKit
//
//  Created by choijunios on 7/10/24.
//

import UIKit
import RxSwift
import PresentationCore

public class IFType2: UIStackView {
    
    // Init parameters
    public private(set) var titleLabelText: String
    public private(set) var placeHolderText: String
    public private(set) var keyboardType: UIKeyboardType
    public private(set) var isCompletionImageAvailable: Bool
    
    // Output
    public var eventPublisher: Observable<String> { self.idleTextField.eventPublisher }
    
    // View
    public private(set) lazy var titleLabel: ResizableUILabel = {
        let label = ResizableUILabel()
        label.text = self.titleLabelText
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    public private(set) lazy var idleTextField = IdleOneLineInputField(
        placeHolderText: placeHolderText,
        keyboardType: keyboardType,
        isCompleteImageAvailable: self.isCompletionImageAvailable
    )
    
    public var uITextField: UITextField { idleTextField.textField }
    
    public override var isFirstResponder: Bool {
        uITextField.isFirstResponder
    }
    
    public var movingView: UIView?
    public var disposeBag = DisposeBag()
    public var prevRect: CGRect = .zero
    public var isPushed: Bool = false
    
    public init(
        titleLabelText: String,
        placeHolderText: String,
        isCompletionImageAvailable: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeHolderText = placeHolderText
        self.titleLabelText = titleLabelText
        self.keyboardType = keyboardType
        self.isCompletionImageAvailable = isCompletionImageAvailable
        super.init(frame: .zero)
        
        setStack()
        setAutoLayout()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    func setStack() {
        
        self.alignment = .leading
        self.axis = .vertical
        self.spacing = 6.0
    }
    
    func setAutoLayout() {
    
        [
            titleLabel,
            idleTextField,
        ].forEach {
            self.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            idleTextField.leftAnchor.constraint(equalTo: self.leftAnchor),
            idleTextField.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }

    public override func resignFirstResponder() -> Bool {
        
        _ = idleTextField.resignFirstResponder()
        
        return super.resignFirstResponder()
    }
}

extension IFType2: IdleKeyboardAvoidable { }
