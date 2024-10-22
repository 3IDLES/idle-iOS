//
//  SetIdPasswordViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import Domain
import DSKit
import PresentationCore
import BaseFeature


import RxSwift
import RxCocoa

protocol SetIdAndPasswordInputable {
    
    // Id
    var editingId: PublishSubject<String> { get set }
    var isIdDuplicatedButtonPressed: PublishSubject<Void> { get set }
    
    // Password
    var editingPassword: PublishSubject<String> { get set }
    var checkingPassword: BehaviorSubject<String> { get set }
}

protocol SetIdAndPasswordOutputable {
    
    // Id
    var idValidationResult: Driver<Bool> { get }
    var idDuplicationCheckResult: Driver<Bool> { get }
    
    // Password
    var passwordValidationState: Driver<PasswordValidationState> { get }
}

class SetIdPasswordViewController<T: ViewModelType>: BaseViewController
where T.Input: SetIdAndPasswordInputable & PageProcessInputable,
      T.Output: SetIdAndPasswordOutputable, T: BaseViewModel {

    
    // View
    let processTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "아이디와 비밀번호를 설정해주세요."
        label.textAlignment = .left
        return label
    }()
    
    // MARK: Id 입력
    let idLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "아이디 설정"
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    let idField: IFType1 = {
        let textField = IFType1(placeHolderText: "아이디를 입력해주세요", submitButtonText: "중복 확인")
        textField.idleTextField.isCompleteImageAvailable = false
        return textField
    }()
    let idGuideLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textString = "* 아이디는 아래의 조건에 맞추어주세요."
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    
    // MARK: 아이디 검증 라벨
    let idValidationIndicator: ValidationIndicator = .init(labelText: "6자~20자 사이")
    
    
    // MARK: 비밀번호 입력
    let passwordLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "비밀번호 설정"
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    let passwordField: IdleOneLineInputField = {
       
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
    let checlPasswordLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "비밀번호 확인"
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .left
        return label
    }()
    let checkPasswordField: IdleOneLineInputField = {
       
        let textField = IdleOneLineInputField(
            placeHolderText: "비밀번호를 한번 더 입력해주세요."
        )
        
        return textField
    }()
    
    let buttonContainer: PrevOrNextContainer = {
        let button = PrevOrNextContainer()
        button.nextButton.label.textString = "완료"
        return button
    }()
    
    init(viewModel: T) {
        
        super.init(nibName: nil, bundle: nil)
        
        super.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        initialUISettuing()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .clear
    }
    
    private func setAppearance() { }
    
    private func setAutoLayout() {
        
        view.layoutMargins = .init(top: 28, left: 20, bottom: 0, right: 20)

        // pw validation indicators
        
        let pwValidationIndicators: VStack = VStack(
            PasswordValidationCase.items.compactMap { item in passwordValidationIndicator[item] },
            spacing: 4,
            alignment: .fill
        )
        
        let scrollView: UIScrollView = .init()
        let scrollView_contentGuide = scrollView.contentLayoutGuide
        let scrollView_frameGuide = scrollView.frameLayoutGuide
        let contentView: UIView = .init()
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contentView.widthAnchor.constraint(equalTo: scrollView_frameGuide.widthAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView_contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView_contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView_contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView_contentGuide.bottomAnchor),
        ])
        
        contentView.layoutMargins = .init(top: 28,left: 20, bottom: 48, right: 20)
        
        [
            idLabel,
            idField,
            idGuideLabel,
            idValidationIndicator,
            passwordLabel,
            passwordField,
            passwordGuideLabel,
            pwValidationIndicators,
            checlPasswordLabel,
            checkPasswordField,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            idLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            idLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            idField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 4),
            idField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            idField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            idGuideLabel.topAnchor.constraint(equalTo: idField.bottomAnchor, constant: 12),
            idGuideLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            idGuideLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            idValidationIndicator.topAnchor.constraint(equalTo: idGuideLabel.bottomAnchor, constant: 6),
            idValidationIndicator.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            idValidationIndicator.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            passwordLabel.topAnchor.constraint(equalTo: idValidationIndicator.bottomAnchor, constant: 24),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 6),
            passwordField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            passwordGuideLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            passwordGuideLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            passwordGuideLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            pwValidationIndicators.topAnchor.constraint(equalTo: passwordGuideLabel.bottomAnchor, constant: 6),
            pwValidationIndicators.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            pwValidationIndicators.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            checlPasswordLabel.topAnchor.constraint(equalTo: pwValidationIndicators.bottomAnchor, constant: 24),
            checlPasswordLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            checlPasswordLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            checkPasswordField.topAnchor.constraint(equalTo: checlPasswordLabel.bottomAnchor, constant: 6),
            checkPasswordField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            checkPasswordField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            checkPasswordField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        
        [
            processTitleLabel,
            
            scrollView,
            
            buttonContainer,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
                
            processTitleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            processTitleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitleLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: processTitleLabel.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: -12),
            
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            buttonContainer.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            buttonContainer.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        ])
    }
    
    private func initialUISettuing() {
        
        idField.button.setEnabled(false)
        
        idValidationIndicator.setState(.invalid)
        passwordValidationIndicator.values.forEach { indicator in
            indicator.setState(.invalid)
        }
        
        // - CTA버튼 비활성화
        buttonContainer.nextButton.setEnabled(false)
    }
    
    private func setObservable() {
        
        guard let viewModel = self.viewModel as? T else { return }
        
        // MARK: Input
        let input = viewModel.input
        
        
        // Id
        idField.idleTextField.textField.rx.text
            .compactMap{ $0 }
            .bind(to: input.editingId)
            .disposed(by: disposeBag)
        
        idField.button.eventPublisher
            .mapToVoid()
            .bind(to: input.isIdDuplicatedButtonPressed)
            .disposed(by: disposeBag)
        
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
        
        // Navigation
        buttonContainer.nextBtnClicked
            .asObservable()
            .bind(to: input.completeButtonClicked)
            .disposed(by: disposeBag)
        
        buttonContainer.prevBtnClicked
            .asObservable()
            .bind(to: input.prevButtonClicked)
            .disposed(by: disposeBag)
        
        
        // MARK: Output
        let output = viewModel.output
        
        // 중복확인이 가능한 아이디인가?
        output
            .idValidationResult
            .drive(onNext: { [weak self] isValid in
                
                guard let self else { return }
                
                // 검증 라벨 색상변경
                
                // 중복확인버튼 활성화
                idField.button.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
        
        let idDuplicationResult = output
            .idDuplicationCheckResult
            .asObservable()
            .share()
        
        idDuplicationResult
            .subscribe(onNext: { [weak self] isValid in
                
                guard let self else { return }
                
                // 비밀번호 필드 활성화
                passwordField.setEnabled(isValid)
                checkPasswordField.setEnabled(isValid)
            })
            .disposed(by: disposeBag)
        
        let passwordValidationResult = output
            .passwordValidationState
            .asObservable()
            .share()
        
        passwordValidationResult
            .subscribe(onNext: { [weak self] state in
                
                guard let self else { return }
                
                // 비밀번호 체킹 상태 업데이트
                
            })
            .disposed(by: disposeBag)
        
    
        
        // id, password 유효성 검사
        Observable
            .combineLatest(
                idDuplicationResult,
                passwordValidationResult
            )
            .map { idIsValid, passwordCheckingState in
                idIsValid && passwordCheckingState.isValid
            }
            .subscribe(onNext: { [weak self] isValid in
                
                guard let self else { return }
                
                buttonContainer.nextButton.setEnabled(isValid)
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
    
    func cleanUp() {
        
    }
}
