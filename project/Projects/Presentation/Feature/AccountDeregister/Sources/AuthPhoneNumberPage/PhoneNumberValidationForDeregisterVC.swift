//
//  PhoneNumberValidationForDeregisterVC.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 8/25/24.
//

import UIKit
import BaseFeature
import PresentationCore
import DSKit


import RxCocoa
import RxSwift

public class PhoneNumberValidationForDeregisterVC: BaseViewController {
    
    // Init
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar()
        bar.titleLabel.textString = "계정 삭제"
        return bar
    }()
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textString = "마지막으로\n전화번호를 인증해주세요"
        return label
    }()
    
    // MARK: 전화번호 입력
    private let phoneNumberLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "전화번호"
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    private let phoneNumberField: IFType1 = {
        
        let textField = IFType1(
            placeHolderText: "전화번호를 입력해주세요.",
            submitButtonText: "인증",
            keyboardType: .numberPad
        )
        textField.idleTextField.isCompleteImageAvailable = false
        
        return textField
    }()
    
    // MARK: 인증번호 입력
    private let authNumberLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "인증번호"
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    private let authNumberField: IFType1 = {
        
        let textField = IFType1(
            placeHolderText: "",
            submitButtonText: "확인",
            keyboardType: .numberPad
        )
        textField.idleTextField.isCompleteImageAvailable = false
        textField.alpha = 0
        return textField
    }()
    private let authSuccessText: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.textString = "* 인증이 완료되었습니다."
        label.textAlignment = .left
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        label.alpha = 0
        return label
    }()
    
    
    let finalWarningLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.textString = "탈퇴 버튼 선택 시 모든 정보가 삭제되며, 되돌릴 수 없습니다."
        label.attrTextColor = DSColor.red100.color
        return label
    }()
    
    let cancelButton: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = "취소하기"
        return button
    }()
    
    let acceptDeregisterButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .mediumRed)
        button.label.textString = "탈퇴하기"
        button.setEnabled(false)
        return button
    }()
    
    public init() {
        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    public required init?(
        coder: NSCoder
    ) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        let textFieldStack = VStack(
            [
                phoneNumberLabel,
                phoneNumberField,
                Spacer(height: 20),
                authNumberLabel,
                authNumberField
            ],
            spacing: 6,
            alignment: .fill
        )
        
        let buttonStack = HStack(
            [
                cancelButton,
                acceptDeregisterButton
            ],
            spacing: 8,
            alignment: .center,
            distribution: .fillEqually
        )
        
        [
            navigationBar,
            titleLabel,
            textFieldStack,
            authSuccessText,
            finalWarningLabel,
            buttonStack,
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            
            textFieldStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            textFieldStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            textFieldStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            
            authSuccessText.topAnchor.constraint(equalTo: textFieldStack.bottomAnchor, constant: 2),
            authSuccessText.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            
            finalWarningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finalWarningLabel.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -12),
            
            buttonStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            buttonStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind(viewModel: PhoneNumberValidationForDeregisterVMable) {
        
        super.bind(viewModel: viewModel)
        
        // Input
        cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonClicked)
            .disposed(by: disposeBag)
        
        navigationBar.backButton.rx.tap
            .bind(to: viewModel.backButtonClicked)
            .disposed(by: disposeBag)
        
        acceptDeregisterButton.rx.tap
            .bind(to: viewModel.deregisterButtonClicked)
            .disposed(by: disposeBag)
        
        // 현재 입력중인 정보 전송
        phoneNumberField.idleTextField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.editingPhoneNumber)
            .disposed(by: disposeBag)
        
        authNumberField.idleTextField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.editingAuthNumber)
            .disposed(by: disposeBag)
        
        // 인증, 확인 버튼이 눌린 경우
        phoneNumberField
            .eventPublisher
            .map { _ in () }
            .bind(to: viewModel.requestAuthForPhoneNumber)
            .disposed(by: disposeBag)
        
        authNumberField
            .eventPublisher
            .map { _ in () }
            .bind(to: viewModel.requestValidationForAuthNumber)
            .disposed(by: disposeBag)
        
        // Output
        
        // 입력중인 전화번호가 특정 조건(ex: 입력길이)을 만족한 경우 '인증'버튼 활성화
        viewModel
            .canSubmitPhoneNumber?
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in self?.phoneNumberField.button.setEnabled($0) })
            .disposed(by: disposeBag)
        
        // 입력중인 인증번호가 특정 조건(ex: 입력길이)을 만족한 경우 '확인'버튼 활성화
        viewModel
            .canSubmitAuthNumber?
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in self?.authNumberField.button.setEnabled($0) })
            .disposed(by: disposeBag)
        
        // 휴대전화 인증의 시작
        viewModel
            .phoneNumberValidation?
            .asObservable()
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                activateAuthNumberField()
            })
            .disposed(by: disposeBag)
        
        // 인증번호 인증 성공여부
        viewModel
            .authNumberValidation?
            .asObservable()
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                acceptDeregisterButton.setEnabled(true)
                
                // 입력과 관려된 필드와 버튼 비활성화
                phoneNumberField.idleTextField.setEnabled(false)
                phoneNumberField.button.setEnabled(false)
                authNumberField.idleTextField.setEnabled(false)
                authNumberField.button.setEnabled(false)
                
                // 타이머 비활성화
                authNumberField.idleTextField.removeTimer()
                
                // 인증 완료 텍스트
                authSuccessText.alpha = 1
            })
            .disposed(by: disposeBag)
    }
    
    func activateAuthNumberField() {
        authNumberField.idleTextField.createTimer()
        authNumberField.idleTextField.startTimer(minute: 5, seconds: 0)
        authNumberField.alpha = 1
        authNumberLabel.alpha = 1
    }
}


