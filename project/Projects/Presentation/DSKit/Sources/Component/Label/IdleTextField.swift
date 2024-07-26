//
//  IdleTextField.swift
//  DSKit
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift

public class IdleTextField: UITextField {
    
    private var currentTypography: Typography
    private var currentText: String = ""
    private var currentTextFieldInsets: UIEdgeInsets = .init(
        top: 10,
        left: 16,
        bottom: 10,
        right: 24
    )
    public var textString: String {
        get {
            return currentText
        }
        set {
            currentText = newValue
            updateText()
        }
    }
    
    public init(typography: Typography) {
        
        self.currentTypography = typography
        
        super.init(frame: .zero)
        
        self.defaultTextAttributes = typography.attributes
        
        self.autocorrectionType = .no
        // 첫 글자 자동 대문자화 끄기
        self.autocapitalizationType = .none
        
        self.contentVerticalAlignment = .center
        
        addToolbar()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
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
    
    private let disposeBag = DisposeBag()
    
    /// 타이포그래피를 변경하면, 앞전에 설정한 속성값을 덥
    public var typography: Typography {
        get {
            currentTypography
        }
        set {
            currentTypography = newValue
            defaultTextAttributes = currentTypography.attributes
            self.updateText()
        }
    }
    
    public var textFieldInsets: UIEdgeInsets {
        
        get {
            currentTextFieldInsets
        }
        set {
            currentTextFieldInsets = newValue
            self.setNeedsLayout()
        }
    }
    
    public var attrPlaceholder: String {
        
        get {
            attributedPlaceholder?.string ?? ""
        }
        set {
            attributedPlaceholder = currentTypography.attributes.toString(
                newValue,
                with: DSKitAsset.Colors.gray200.color
            )
        }
    }
    private func updateText() {
        self.rx.attributedText.onNext(NSAttributedString(string: textString, attributes: currentTypography.attributes))
    }
}


public extension IdleTextField {
    
    // 텍스트 영역의 프레임을 반환
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        let height = (currentTypography.attributes[.font] as! UIFont).lineHeight
        
        let verticalInset = currentTextFieldInsets.top + currentTextFieldInsets.bottom
        
        let topInset = (currentTypography.lineHeight+(verticalInset) - height) * (currentTextFieldInsets.top/verticalInset)
        let bottomInset = (currentTypography.lineHeight+(verticalInset) - height) * (currentTextFieldInsets.bottom/verticalInset)
        
        return bounds.inset(by: .init(
            top: topInset,
            left: currentTextFieldInsets.left,
            bottom: bottomInset,
            right: currentTextFieldInsets.right
        ))
    }
    
    // 편집 중일 때 텍스트 영역의 프레임을 반환
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        let height = (currentTypography.attributes[.font] as! UIFont).lineHeight
        
        let verticalInset = currentTextFieldInsets.top + currentTextFieldInsets.bottom
        
        let topInset = (currentTypography.lineHeight+(verticalInset) - height) * (currentTextFieldInsets.top/verticalInset)
        let bottomInset = (currentTypography.lineHeight+(verticalInset) - height) * (currentTextFieldInsets.bottom/verticalInset)
        
        return bounds.inset(by: .init(
            top: topInset,
            left: currentTextFieldInsets.left,
            bottom: bottomInset,
            right: currentTextFieldInsets.right
        ))
    }
    
    // 플레이스홀더 텍스트 영역의 프레임을 반환
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        let height = (currentTypography.attributes[.font] as! UIFont).lineHeight
        
        let verticalInset = currentTextFieldInsets.top + currentTextFieldInsets.bottom
        
        let topInset = (currentTypography.lineHeight+(verticalInset) - height) * (currentTextFieldInsets.top/verticalInset)
        let bottomInset = (currentTypography.lineHeight+(verticalInset) - height) * (currentTextFieldInsets.bottom/verticalInset)
        
        return bounds.inset(by: .init(
            top: topInset,
            left: currentTextFieldInsets.left,
            bottom: bottomInset,
            right: currentTextFieldInsets.right
        ))
    }
}
