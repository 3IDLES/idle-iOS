//
//  SetIdPasswordViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import Entity
import DSKit
import RxSwift
import RxCocoa
import PresentationCore

public protocol SetIdPasswordInputable {
    var editingId: PublishRelay<String?> { get set }
    var editingPassword: PublishRelay<(pwd: String, cpwd: String)?> { get set }
    var requestIdDuplicationValidation: PublishRelay<String?> { get set }
}

public protocol SetIdPasswordOutputable {
    
    var canCheckIdDuplication: PublishRelay<Bool?> { get set }
    var idDuplicationValidation: PublishRelay<String?> { get set }
    var passwordValidation: PublishRelay<PasswordValidationState?> { get set }
}

class SetIdPasswordViewController<T: ViewModelType>: DisposableViewController
where T.Input: SetIdPasswordInputable & CTAButtonEnableInputable, T.Output: SetIdPasswordOutputable & RegisterSuccessOutputable {
    
    var coordinator: CenterRegisterCoordinator?
    
    private let viewModel: T
    
    // View
    private let processTitle: ResizableUILabel = {
       
        let label = ResizableUILabel()
        
        label.text = "아이디와 비밀번호를 설정해주세요."
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 20)
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: Id 입력
    private let idLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        label.text = "아이디 설정"
        label.textAlignment = .left
        
        return label
    }()
    private let idField: IFType1 = {
        
       let textField = IFType1(
        placeHolderText: "아이디를 입력해주세요",
        submitButtonText: "중복 확인"
       )
        
        textField.idleTextField.isCompleteImageAvailable = false
        
        return textField
    }()
    private let thisIsValidIdLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 12)
        label.text = "사용 가능한 아이디입니다."
        label.textColor = DSKitAsset.Colors.gray300.color
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: 비밀번호 입력
    private let passwordLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        label.text = "비밀번호 설정"
        label.textAlignment = .left
        
        return label
    }()
    private let passwordField: IdleOneLineInputField = {
       
        let textField = IdleOneLineInputField(
            placeHolderText: "비밀번호를 입력해주세요."
        )
        
        return textField
    }()
    private let thisIsValidPasswordLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 12)
        label.text = "사용 가능한 비밀번호입니다."
        label.textColor = DSKitAsset.Colors.gray300.color
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: 비밀번호 확인 입력
    private let checlPasswordLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        label.text = "비밀번호 확인"
        label.textAlignment = .left
        
        return label
    }()
    private let checkPasswordField: IdleOneLineInputField = {
       
        let textField = IdleOneLineInputField(
            placeHolderText: "비밀번호를 한번 더 입력해주세요."
        )
        
        return textField
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "완료")
        
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(coordinator: CenterRegisterCoordinator?, viewModel: T) {
        
        self.coordinator = coordinator
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
        
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            processTitle,
            idLabel,
            idField,
            thisIsValidIdLabel,
            passwordLabel,
            passwordField,
            thisIsValidPasswordLabel,
            checlPasswordLabel,
            checkPasswordField,
            ctaButton,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
                
            processTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            idLabel.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            idLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            idField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 4),
            idField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            idField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            thisIsValidIdLabel.topAnchor.constraint(equalTo: idField.bottomAnchor, constant: 6),
            thisIsValidIdLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            thisIsValidIdLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordLabel.topAnchor.constraint(equalTo: idField.bottomAnchor, constant: 32),
            passwordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 6),
            passwordField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            thisIsValidPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 6),
            thisIsValidPasswordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            thisIsValidPasswordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            checlPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 32),
            checlPasswordLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            checlPasswordLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            checkPasswordField.topAnchor.constraint(equalTo: checlPasswordLabel.bottomAnchor, constant: 6),
            checkPasswordField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            checkPasswordField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func initialUISettuing() {
        
        idField.button.setEnabled(false)
        
        thisIsValidIdLabel.isHidden = true
        thisIsValidPasswordLabel.isHidden = true
        
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
    }
    
    private func setObservable() {
        
        // MARK: Input
        let input = viewModel.input
        
        // 현재 입력중인 정보 전송
        idField.idleTextField.textField.rx.text
            .bind(to: input.editingId)
            .disposed(by: disposeBag)
        
        
        Observable
            .combineLatest(
                passwordField.eventPublisher,
                checkPasswordField.eventPublisher
            )
            .map({ ($0, $1) })
            .bind(to: input.editingPassword)
            .disposed(by: disposeBag)
        
        ctaButton
            .eventPublisher
            .bind(to: input.ctaButtonClicked)
            .disposed(by: disposeBag)
        
        // id 중복확인 요청 버튼
        idField.eventPublisher
            .map { [weak self] in
                // 증복검사 실행시 아이디 입력 필드 비활성화
                self?.idField.idleTextField.setEnabled(false)
                self?.idField.button.setEnabled(false)
                return $0
            }
            .bind(to: input.requestIdDuplicationValidation)
            .disposed(by: disposeBag)
        
        // MARK: Output
        let output = viewModel.output
        
        // 중복확인이 가능한 아이디인가?
        output
            .canCheckIdDuplication
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?.idField.button.setEnabled($0)
            })
            .disposed(by: disposeBag)
        
        // 아이디 중복확인 결과
        let idDuplicationValidation = output
            .idDuplicationValidation
            .compactMap { [weak self] checkedId in
                // 아이디 입력 필드 활성화
                self?.idField.idleTextField.setEnabled(true)
                return checkedId
            }
        
        // 중복검사를 통과한 아이디와 입력창의 아이디가 일치하는지 확인한다.
        let finalIdValidation = Observable
            .combineLatest(
                idField.idleTextField.eventPublisher,
                idDuplicationValidation
            )
            .observe(on: MainScheduler.instance)
            .map { [weak self] (editingId, validId) in
                let isValid = editingId == validId
                self?.thisIsValidIdLabel.isHidden = !isValid
                return isValid
            }

        // 비밀번호 검증
        let finalPaswordValidation = output
            .passwordValidation
            .compactMap { $0 }
            .map({ [weak self] validationState in
                switch validationState {
                    
                case .invalidPassword:
                    printIfDebug("❌ 비밀번호가 유효하지 않습니다.")
                    self?.onPasswordUnMatched()
                    return false
                case .unMatch:
                    printIfDebug("☑️ 비밀번호가 일치하지 않습니다.")
                    self?.onPasswordUnMatched()
                    return false
                case .match:
                    printIfDebug("✅ 비밀번호가 일치합니다.")
                    self?.onPasswordMatched()
                    self?.ctaButton.setEnabled(true)
                    return true
                }
            })
        
        // id, password 유효성 검사
        Observable
            .combineLatest(
                finalIdValidation,
                finalPaswordValidation
            )
            .map { $0 && $1 }
            .subscribe(onNext: { [weak self] in self?.ctaButton.setEnabled($0) })
            .disposed(by: disposeBag)
        
        
        output
            .registerValidation
            .compactMap { $0 }
            .subscribe { [weak self] isSuccess in
                if isSuccess {
                    // 회원가입 성공
                    self?.coordinator?.next()
                } else {
                    // 회원가입실패
                    self?.ctaButton.setEnabled(true)
                }
            }
            .disposed(by: disposeBag)
    
        
        // MARK: ViewController한정 로직
        // CTA버튼 클릭시 버튼 비활성화
        ctaButton
            .eventPublisher
            .subscribe { [weak self] _ in
                
                self?.ctaButton.setEnabled(false)
            }
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
