//
//  IdleTextField.swift
//  DSKit
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift
import PresentationCore

/// 기본이 되는 텍스트 필드입니다.
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
    
    public let disposeBag = DisposeBag()
    
    // 키보드 어보이던스가 적용될 뷰입니다.
    public weak var movingView: UIView?
    
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
        setInset(bounds: bounds)
    }
    
    // 편집 중일 때 텍스트 영역의 프레임을 반환
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        setInset(bounds: bounds)
    }
    
    // 플레이스홀더 텍스트 영역의 프레임을 반환
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        setInset(bounds: bounds)
    }
    
    private func setInset(bounds: CGRect) -> CGRect {
        let height = (currentTypography.attributes[.font] as! UIFont).lineHeight
        
        let verticalInset = currentTextFieldInsets.top + currentTextFieldInsets.bottom
        
        // 실제 폰트와 attribute의 라인 Height이 상이함으로 이를 조정하는 과정입니다.
        var topInset: CGFloat = 0
        var bottomInset: CGFloat = 0
        
        if verticalInset > 0 {
            topInset = (currentTypography.lineHeight+verticalInset - height) * (currentTextFieldInsets.top/verticalInset)
            
            bottomInset = (currentTypography.lineHeight+verticalInset - height) * (currentTextFieldInsets.bottom/verticalInset)
        }
        
        return bounds.inset(by: .init(
            top: topInset,
            left: currentTextFieldInsets.left,
            bottom: bottomInset,
            right: currentTextFieldInsets.right
        ))
    }
}

extension IdleTextField: IdleKeyboardAvoidable { }
