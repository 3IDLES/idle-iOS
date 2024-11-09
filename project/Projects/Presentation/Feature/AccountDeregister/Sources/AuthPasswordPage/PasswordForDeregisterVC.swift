//
//  PasswordForDeregisterVC.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public class PasswordForDeregisterVC: BaseViewController {
    
    // Init
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(innerViews: [])
        bar.titleLabel.textString = "계정 삭제"
        return bar
    }()
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textString = "마지막으로\n비밀번호를 입력해주세요"
        return label
    }()
    
    let passwordField: IdleOneLineInputField = {
        let field = IdleOneLineInputField(placeHolderText: "비밀번호를 입력해주세요")
        return field
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
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
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
        
        let passwordLabel = IdleLabel(typography: .Subtitle4)
        passwordLabel.textString = "비밀번호"
        passwordLabel.textColor = DSColor.gray500.color
        passwordLabel.textAlignment = .left
        
        let textFieldStack = VStack(
            [
                passwordLabel,
                passwordField,
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
            
            finalWarningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finalWarningLabel.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -12),
            
            buttonStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            buttonStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
    }
    
    private func setObservable() {
        passwordField
            .eventPublisher
            .map { password in
                password.count > 0
            }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isValid in
                self?.acceptDeregisterButton.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: PasswordForDeregisterVM) {
        
        super.bind(viewModel: viewModel)
        
        // Input
        acceptDeregisterButton
            .rx.tap
            .withLatestFrom(passwordField.eventPublisher)
            .bind(to: viewModel.deregisterButtonClicked)
            .disposed(by: disposeBag)
    
        cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonClicked)
            .disposed(by: disposeBag)
        
        navigationBar.backButton.rx.tap
            .bind(to: viewModel.backButtonClicked)
            .disposed(by: disposeBag)
    }
}

