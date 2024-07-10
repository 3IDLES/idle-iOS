//
//  IFType2.swift
//  DSKit
//
//  Created by choijunios on 7/10/24.
//

import UIKit
import RxSwift

public class IFType2: UIStackView {
    
    // Init parameters
    public private(set) var titleLabelText: String
    public private(set) var placeHolderText: String
    public private(set) var keyboardType: UIKeyboardType
    public private(set) var isCompletionImageAvailable: Bool
    
    // Output
    public var eventPublisher: Observable<String> { self.textField.eventPublisher }
    
    // View
    public private(set) lazy var titleLabel: ResizableUILabel = {
        let label = ResizableUILabel()
        label.text = self.titleLabelText
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    public private(set) lazy var textField = IdleOneLineInputField(
        placeHolderText: placeHolderText,
        keyboardType: keyboardType,
        isCompleteImageAvailable: self.isCompletionImageAvailable
    )
    
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
            textField,
        ].forEach {
            self.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: self.leftAnchor),
            textField.rightAnchor.constraint(equalTo: self.rightAnchor),
        ])
    }

    public override func resignFirstResponder() -> Bool {
        
        _ = textField.resignFirstResponder()
        
        return super.resignFirstResponder()
    }
}
