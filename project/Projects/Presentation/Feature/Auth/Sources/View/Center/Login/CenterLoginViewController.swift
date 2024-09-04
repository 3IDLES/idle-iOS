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
    
    // View
    private let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(titleText: "로그인")
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
    
    public init(viewModel: CenterLoginViewModel) {
        
        super.init(nibName: nil, bundle: nil)
        
        super.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        setObservable()
        setKeyboardAvoidance()
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
            
            navigationBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
        
        guard let viewModel = self.viewModel as? CenterLoginViewModel else { return }
        
        // MARK: Input
        let input = viewModel.input
        
        navigationBar.backButton.rx.tap.bind(to: input.backButtonClicked)
            .disposed(by: disposeBag)
        
        // 인풋 전달
        idField.uITextField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingId)
            .disposed(by: disposeBag)
        
        passwordField.uITextField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingPassword)
            .disposed(by: disposeBag)
        
        forgotPasswordButton.eventPublisher
            .bind(to: input.setNewPasswordButtonClicked)
            .disposed(by: disposeBag)
        
        // 로그인 버튼 눌림
        ctaButton.eventPublisher
            .bind(to: input.loginButtonPressed)
            .disposed(by: disposeBag)
        
        let output = viewModel.output
        
        // 로그인 시도 결과 수신
        viewModel
            .alert?
            .drive(onNext: { [weak self] alertVO in
                guard let self else { return }
                
                // 비밀번호 입력창 반응
                
                loginFailedText.isHidden = false
                passwordField.idleTextField.onCustomState { textField in
                    textField.layer.borderColor = DSKitColors.Color.red.cgColor
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setKeyboardAvoidance() {
        [
            idField.idleTextField,
            passwordField.idleTextField
        ].forEach { (view: IdleKeyboardAvoidable) in
            view.setKeyboardAvoidance(movingView: inputStack)
        }
    }
}
