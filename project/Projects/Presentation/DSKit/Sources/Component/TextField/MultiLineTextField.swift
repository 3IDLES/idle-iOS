//
//  MultiLineTextField.swift
//  DSKit
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore

public class MultiLineTextField: UITextView {
    
    private var currentText: String = ""
    
    lazy var placeHolderLabel: IdleLabel = {
        let label = IdleLabel(typography: typography)
        label.attrTextColor = DSKitAsset.Colors.gray200.color
        label.textAlignment = .left
        return label
    }()
    
    public var placeholderText: String {
        get {
            placeHolderLabel.textString
        }
        set {
            placeHolderLabel.textString = newValue
        }
    }
    public let typography: Typography
    
    public var textString: String {
        get {
            return currentText
        }
        set {
            currentText = newValue
            updateText()
        }
    }
    
    public let disposeBag = DisposeBag()
    
    // 키보드 어보이던스가 적용될 뷰입니다.
    public weak var movingView: UIView?
    public var prevRect: CGRect = .zero
    public var isPushed: Bool = false
    
    public init(typography: Typography, placeholderText: String = "") {
        
        self.typography = typography
        
        super.init(frame: .zero, textContainer: nil)
        
        self.placeholderText = placeholderText
        
        setAppearance()
        setPlacholderLabel()
        addToolbar()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setAppearance() {
        // Delegate
        self.delegate = self
        
        // border
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6
        
        // textContainer
        self.textContainerInset = .init(top: 12, left: 16, bottom: 16, right: 16)
        self.textContainer.lineFragmentPadding = 0
        
        // font
        self.typingAttributes = typography.attributes
        
        // Scroll
        self.isScrollEnabled = true
    }
    
    private func setPlacholderLabel() {
        
        self.addSubview(placeHolderLabel)
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeHolderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: self.textContainerInset.top),
            placeHolderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.textContainerInset.left),
            placeHolderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: self.textContainerInset.right),
        ])
    }
    
    public func addToolbar() {
        // TextField toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // flexibleSpace 추가
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let closeButton = UIBarButtonItem()
        closeButton.title = "완료"
        closeButton.style = .done
        toolbar.setItems([
            flexibleSpace,
            closeButton
        ], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        self.inputAccessoryView = toolbar
        
        closeButton.rx.tap.subscribe { [weak self] _ in
            self?.resignFirstResponder()
        }
        .disposed(by: disposeBag)
    }
    
    private func updateText() {
        
        self.rx.attributedText.onNext(NSAttributedString(string: textString, attributes: typography.attributes))
    }
}

extension MultiLineTextField: UITextViewDelegate {
    
    // UITextViewDelegate 메서드: 텍스트 뷰가 편집을 시작할 때 호출
    public func textViewDidBeginEditing(_ textView: UITextView) {
        placeHolderLabel.isHidden = true
    }
    
    // UITextViewDelegate 메서드: 텍스트 뷰가 편집을 끝낼 때 호출
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.attributedText.string.isEmpty {
            placeHolderLabel.isHidden = false
        }
    }
}

extension MultiLineTextField: IdleKeyboardAvoidable { }
