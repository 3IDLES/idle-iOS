//
//  ValidateNewPasswordViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/16/24.
//

import UIKit
import DSKit
import RxCocoa
import RxSwift
import PresentationCore
import BaseFeature

public protocol ChangePasswordSuccessInputable {
    var changePasswordButtonClicked: PublishRelay<Void> { get }
}

public protocol ChangePasswordSuccessOutputable {
    var changePasswordValidation: Driver<Bool>? { get set }
}

class ValidateNewPasswordViewController<T: ViewModelType>: BaseViewController
where T.Input: SetPasswordInputable & ChangePasswordSuccessInputable,
      T.Output: SetPasswordOutputable & ChangePasswordSuccessOutputable, T: BaseViewModel {
    
    var coordinator: Coordinator?
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "새로운 비밀번호를 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    // MARK: 비밀번호 입력
    private let passwordLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "비밀번호 설정"
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .left
        return label
    }()
    private let passwordField: IdleOneLineInputField = {
        let textField = IdleOneLineInputField(
            placeHolderText: "비밀번호를 입력해주세요."
        )
        return textField
    }()
    private let thisIsValidPasswordLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.textString = "* 사용 가능한 비밀번호입니다."
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    // MARK: 비밀번호 확인 입력
    private let checlPasswordLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "비밀번호 확인"
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .left
        return label
    }()
    private let checkPasswordField: IdleOneLineInputField = {
       
        let textField = IdleOneLineInputField(
            placeHolderText: "비밀번호를 한번 더 입력해주세요."
        )
        
        return textField
    }()
    private let passwordDoesntMathLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.textString = "* 비밀번호를 다시 확인해주세요."
        label.attrTextColor = DSKitAsset.Colors.red100.color
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "완료")
        
        return button
    }()
    
    public init(coordinator: Coordinator, viewModel: T) {
        
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
        
        super.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        initialUISettuing()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        
        view.backgroundColor = .clear
    }
    
    private func setAppearance() {
        
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            processTitle,
            passwordLabel,
            passwordField,
            thisIsValidPasswordLabel,
            checlPasswordLabel,
            checkPasswordField,
            passwordDoesntMathLabel,
            ctaButton,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
                
            processTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordLabel.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            passwordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 6),
            passwordField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            thisIsValidPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 2),
            thisIsValidPasswordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            thisIsValidPasswordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            checlPasswordLabel.topAnchor.constraint(equalTo: thisIsValidPasswordLabel.bottomAnchor, constant: 12),
            checlPasswordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            checlPasswordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            checkPasswordField.topAnchor.constraint(equalTo: checlPasswordLabel.bottomAnchor, constant: 6),
            checkPasswordField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            checkPasswordField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordDoesntMathLabel.topAnchor.constraint(equalTo: checkPasswordField.bottomAnchor, constant: 2),
            passwordDoesntMathLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordDoesntMathLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func initialUISettuing() {
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
    }
    
    func setObservable() {
        
        guard let viewModel = self.viewModel as? T else { return }
        
        // MARK: Input
        let input = viewModel.input
        
        Observable
            .combineLatest(
                passwordField.eventPublisher,
                checkPasswordField.eventPublisher
            )
            .map({ ($0, $1) })
            .bind(to: input.editingPasswords)
            .disposed(by: disposeBag)
        
        ctaButton
            .eventPublisher
            .map { [weak self] _ in
                self?.ctaButton.setEnabled(false)
            }
            .bind(to: input.changePasswordButtonClicked)
            .disposed(by: disposeBag)
        
        
        // MARK: Output
        let output = viewModel.output
        
        // 비밀번호 검증
        output
            .passwordValidation?
            .drive(onNext: { [weak self] validationState in
                
                guard let self else { return }
                
                switch validationState {
                case .invalidPassword:
                    thisIsValidPasswordLabel.alpha = 0
                    onPasswordUnMatched()
                case .unMatch:
                    thisIsValidPasswordLabel.alpha = 1
                    passwordDoesntMathLabel.alpha = 1
                    onPasswordUnMatched()
                case .match:
                    thisIsValidPasswordLabel.alpha = 1
                    passwordDoesntMathLabel.alpha = 0
                    onPasswordMatched()
                    ctaButton.setEnabled(true)
                }
            })
            .disposed(by: disposeBag)
        
        output
            .changePasswordValidation?
            .drive (onNext: { [weak self] isSuccess in
                
                if isSuccess {
                    // 비밀번호 변경 성공
                    self?.coordinator?.next()
                    
                } else {
                    // 비밀번호 변경 실패
                    self?.ctaButton.setEnabled(true)
                }
            })
            .disposed(by: disposeBag)
    
    }
    
    private func onPasswordMatched() {
        
        passwordField.setState(state: .complete)
        checkPasswordField.setState(state: .complete)
    }
    
    private func onPasswordUnMatched() {
        
        passwordField.setState(state: .editing)
        checkPasswordField.setState(state: .editing)
    }
}
