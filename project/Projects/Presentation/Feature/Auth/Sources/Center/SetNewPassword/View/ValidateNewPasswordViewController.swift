//
//  ValidateNewPasswordViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/16/24.
//

import UIKit

import BaseFeature
import DSKit
import PresentationCore
import Domain

import RxCocoa
import RxSwift

protocol ChangePasswordSuccessInputable {
    var editingPassword: PublishSubject<String> { get set }
    var checkingPassword: BehaviorSubject<String> { get set }
    var changePasswordButtonClicked: PublishRelay<Void> { get }
}

protocol ChangePasswordSuccessOutputable {
    var passwordValidationState: Driver<PasswordValidationState> { get }
}

class ValidateNewPasswordViewController<T: ViewModelType>: UIViewController
where T.Input: ChangePasswordSuccessInputable, T.Output: ChangePasswordSuccessOutputable {
    
    let viewModel: T
    
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
    let passwordGuideLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textString = "* 비밀번호는 아래의 조건에 맞추어주세요."
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    
    // MARK: 비밀번호 검증 라벨
    let passwordValidationIndicator: [PasswordValidationCase: ValidationIndicator] = {
        var dict: [PasswordValidationCase: ValidationIndicator] = [:]
        for item in PasswordValidationCase.items {
            dict[item] = ValidationIndicator(labelText: item.indicatorText)
        }
        return dict
    }()
    
    // MARK: 비밀번호 확인 입력
    private let checkPasswordLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "비밀번호 확인"
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .left
        return label
    }()
    private let checkPasswordField: IdleOneLineInputField = {
        let textField = IdleOneLineInputField(placeHolderText: "비밀번호를 한번 더 입력해주세요.")
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
    
    let disposeBag = DisposeBag()
    
    public init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
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
        
        view.layoutMargins = .init(top: 50, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        // pw validation indicators
        
        let pwValidationIndicators: VStack = VStack(
            PasswordValidationCase.items.compactMap { item in passwordValidationIndicator[item] },
            spacing: 4,
            alignment: .fill
        )
        
        [
            processTitle,
            passwordLabel,
            passwordField,
            passwordGuideLabel,
            pwValidationIndicators,
            checkPasswordLabel,
            checkPasswordField,
            passwordDoesntMathLabel,
            ctaButton,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
                
            processTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordLabel.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            passwordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 6),
            passwordField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordGuideLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            passwordGuideLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordGuideLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            pwValidationIndicators.topAnchor.constraint(equalTo: passwordGuideLabel.bottomAnchor, constant: 6),
            pwValidationIndicators.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            pwValidationIndicators.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            checkPasswordLabel.topAnchor.constraint(equalTo: pwValidationIndicators.bottomAnchor, constant: 12),
            checkPasswordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            checkPasswordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            checkPasswordField.topAnchor.constraint(equalTo: checkPasswordLabel.bottomAnchor, constant: 6),
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
        
        passwordValidationIndicator.values.forEach { indicator in
            indicator.setState(.invalid)
        }
        
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
    }
    
    func setObservable() {
        
        // MARK: Input
        let input = viewModel.input
        
        // Password
        passwordField
            .textField.rx.text
            .compactMap{ $0 }
            .bind(to: input.editingPassword)
            .disposed(by: disposeBag)
        
        checkPasswordField
            .textField.rx.text
            .compactMap{ $0 }
            .bind(to: input.checkingPassword)
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
        
        output
            .passwordValidationState
            .drive(onNext: { [weak self] state in
                
                guard let self else { return }
                
                // 비밀번호 체킹 상태 업데이트
                passwordValidationIndicator[.characterCount]?.setState(
                    state.characterCount == .valid ? .valid : .invalid
                )
                passwordValidationIndicator[.alphabetAndNumberIncluded]?.setState(
                    state.alphabetAndNumberIncluded == .valid ? .valid : .invalid
                )
                passwordValidationIndicator[.noEmptySpace]?.setState(
                    state.noEmptySpace == .valid ? .valid : .invalid
                )
                passwordValidationIndicator[.unsuccessiveSame3words]?.setState(
                    state.unsuccessiveSame3words == .valid ? .valid : .invalid
                )
                
                // 확인버튼 활성화
                ctaButton.setEnabled(state.isValid)
            })
            .disposed(by: disposeBag)
    }
}
