//
//  CenterLoginViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import RxSwift
import DSKit
import PresentationCore
import BaseFeature

public class CenterLoginViewController: BaseViewController {
    
    let viewModel: CenterLoginViewModel
    
    var coordinator: CenterLoginCoordinator?
    
    // View
    private let navigationBar: NavigationBarType1 = {
       
        let bar = NavigationBarType1(navigationTitle: "로그인")
        
        return bar
    }()
    
    private let idField: IFType2 = {
        
        let field = IFType2(
            titleLabelText: "아이디",
            placeHolderText: "아이디를 입력해주세요.",
            isCompletionImageAvailable: false
        )
        
        return field
    }()
    private let passwordField: IFType2 = {
        
        let field = IFType2(
            titleLabelText: "비밀번호",
            placeHolderText: "비밀번호를 입력해주세요.",
            isCompletionImageAvailable: false
        )
        
        return field
    }()
    
    private let inputStack: UIStackView = {
       
        let stack = UIStackView()
        
        stack.axis = .vertical
        stack.spacing = 30
        stack.alignment = .fill
        
        return stack
    }()
    
    private let loginFailedText: ResizableUILabel = {
       
        let label = ResizableUILabel()
        
        label.text = "비밀번호를 다시 확인해 주세요"
        label.font = DSKitFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DSKitColors.Color.red
        label.isHidden = true
        
        return label
    }()
    
    private let forgotPasswordButton: TextButtonType3 = {
        
        let button = TextButtonType3(typography: .Body2)
        
        button.textString = "비밀번호가 기억나지 않나요?"
        button.attrTextColor = DSKitAsset.Colors.gray500.color
        button.setAttr(attr: .underlineStyle, value: NSUnderlineStyle.single.rawValue)
        button.setAttr(attr: .underlineColor, value: DSKitAsset.Colors.gray500.color)
        
        return button
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "로그인")
        
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(coordinator: CenterLoginCoordinator? = nil, viewModel: CenterLoginViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setAppearance() {
        
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 16, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            idField,
            passwordField,
        ].forEach {
            inputStack.addArrangedSubview($0)
        }
        
        [
            navigationBar,
            inputStack,
            forgotPasswordButton,
            ctaButton,
            loginFailedText,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            view.bringSubviewToFront($0)
        }
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 12),
            
            inputStack.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 125),
            inputStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            inputStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            loginFailedText.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loginFailedText.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: 4),
            
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -16),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
    }
    
    private func setObservable() {
        
        setKeyboardAvoidance()
        
        // MARK: Input
        let input = viewModel.input
        
        // 인풋 전달
        idField.uITextField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingId)
            .disposed(by: disposeBag)
        
        passwordField.uITextField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingPassword)
            .disposed(by: disposeBag)
        
        // 로그인 버튼 눌림
        ctaButton.eventPublisher
            .bind(to: input.loginButtonPressed)
            .disposed(by: disposeBag)
        
        let output = viewModel.output
        
        // 로그인 시도 결과 수신
        output
            .loginValidation?
            .drive(onNext: { [weak self] isSuccess in
                if isSuccess {
                    self?.onLoginSucceed()
                } else {
                    self?.onLoginFailed()
                }
            })
            .disposed(by: disposeBag)
        
        // MARK: ViewController 내부에서 진행되는 로직
        navigationBar
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
            }
            .disposed(by: disposeBag)
        
        forgotPasswordButton
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.coordinator?.parent?.setNewPassword()
            }
            .disposed(by: disposeBag)
    }
    
    private func onLoginFailed() {
        
        loginFailedText.isHidden = false
        passwordField
            .idleTextField
            .onCustomState { textField in
                textField.layer.borderColor = DSKitColors.Color.red.cgColor
            }
    }
    
    private func onLoginSucceed() {
        
        loginFailedText.isHidden = true
        passwordField
            .idleTextField
            .onCustomState { textField in
                textField.layer.borderColor = textField.normalBorderColor.cgColor
            }
        
        coordinator?.parent?.authFinished()
    }
    
    public func cleanUp() {
        
    }
}

extension CenterLoginViewController {
    
    
    private func setKeyboardAvoidance() {
        
        // 키보드 어보이던스 설정
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAction(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAction(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func onKeyboardAction(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
            
            guard let self else { return }
            
            if notification.name == UIResponder.keyboardWillShowNotification {
                
                let movingView: UIView!
                
                if self.idField.uITextField.isFirstResponder {
                    // id field가 선택된 경우
                    movingView = self.idField
                } else if self.passwordField.uITextField.isFirstResponder {
                    // password field가 선택된 경우
                    movingView = self.passwordField
                } else { return }
                
                let idFieldFrame = movingView.convert(movingView.bounds, to: nil)
                let maxY = idFieldFrame.origin.y + idFieldFrame.height
                
                if maxY > keyboardFrame.origin.y {
                    // 키보드가 field를 가리는 경우
                    let diff = maxY - keyboardFrame.origin.y
                    let inset: CGFloat = 10
                    
                    inputStack.transform = CGAffineTransform(translationX: 0, y: -(diff+inset))
                }
                
            } else {
                
                // 키보드가 사라자니는 경우
                self.inputStack.transform = .identity
            }
        }, completion: nil)
    }
}
