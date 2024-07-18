//
//  MultiLineTextField.swift
//  DSKit
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import RxSwift
import RxCocoa

public class MultiLineTextField: UITextView {
    
    private var currentText: String = ""
    
    public var placeholderText: String
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
    
    private let disposeBag = DisposeBag()
    
    public init(typography: Typography, placeholderText: String = "") {
        self.placeholderText = placeholderText
        self.typography = typography
        
        super.init(frame: .zero, textContainer: nil)
        
        setAppearance()
        setPlaceholderText(textView: self)
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
        if textView.text == placeholderText {
            textView.attributedText = .none
            textView.textColor = DSKitAsset.Colors.gray900.color
        }
    }
    
    // UITextViewDelegate 메서드: 텍스트 뷰가 편집을 끝낼 때 호출
    public func textViewDidEndEditing(_ textView: UITextView) {
        setPlaceholderText(textView: textView)
    }
    
    private func setPlaceholderText(textView: UITextView) {
        if textView.attributedText.string.isEmpty {
            textView.attributedText = self.typography.attributes.toString(placeholderText)
            textView.textColor = DSKitAsset.Colors.gray200.color
        }
    }
    
}
