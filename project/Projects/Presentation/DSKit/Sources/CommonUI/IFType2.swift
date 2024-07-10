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
    
    // Observable
    /// 버튼을 누를시 텍스트를 반환하는 event publisher입니다.
    public let eventPublisher: PublishSubject<String> = .init()
    
    // View
    public private(set) lazy var titleLabel: ResizableUILabel = {
        let label = ResizableUILabel()
        label.text = titleLabelText
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    public private(set) lazy var textField = IdleOneLineInputField(
        placeHolderText: placeHolderText,
        keyboardType: keyboardType
    )
    
    public init(
        titleLabelText: String,
        placeHolderText: String,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeHolderText = placeHolderText
        self.titleLabelText = titleLabelText
        self.keyboardType = keyboardType
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
