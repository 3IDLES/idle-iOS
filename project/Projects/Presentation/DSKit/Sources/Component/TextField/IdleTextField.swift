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
    
    public override var intrinsicContentSize: CGSize {
        
        return .init(
            width: super.intrinsicContentSize.width,
            height: typography.lineHeight ?? super.intrinsicContentSize.height
        )
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
