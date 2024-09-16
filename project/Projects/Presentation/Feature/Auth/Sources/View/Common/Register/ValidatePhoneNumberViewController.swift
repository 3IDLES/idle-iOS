//
//  ValidatePhoneNumberViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import DSKit
import Entity
import PresentationCore
import BaseFeature

public protocol AuthPhoneNumberInputable {
    
    var editingPhoneNumber: BehaviorRelay<String> { get set }
    var editingAuthNumber: BehaviorRelay<String> { get set }
    var requestAuthForPhoneNumber: PublishRelay<Void> { get set }
    var requestValidationForAuthNumber: PublishRelay<Void> { get set }
    var alert: PublishSubject<DefaultAlertContentVO> { get }
}

public protocol AuthPhoneNumberOutputable {
    
    var canSubmitPhoneNumber: Driver<Bool>? { get set }
    var canSubmitAuthNumber: Driver<Bool>? { get set }
    var phoneNumberValidation: Driver<Bool>? { get set }
    var authNumberValidation: Driver<Bool>? { get set }
    
    // 요양보호사 로그인에 성공한 경우(요양보호사 한정 로직)
    var loginSuccess: Driver<Void>? { get set }
}

class ValidatePhoneNumberViewController<T: ViewModelType>: UIViewController
where
    T.Input: AuthPhoneNumberInputable & PageProcessInputable,
    T.Output: AuthPhoneNumberOutputable {
    
    let viewModel: T
    
    // View
    private let processTitle: ResizableUILabel = {
       
        let label = ResizableUILabel()
        
        label.text = "전화번호를 입력해주세요."
        label.font = DSKitFontFamily.Pretendard.bold.font(size: 20)
        label.textAlignment = .left
        
        return label
    }()
    
    // MARK: 전화번호 입력
    private let phoneNumberLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "전화번호"
        label.attrTextColor = DSKitAsset.Colors.gray500.color
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
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textAlignment = .left
        return label
    }()
        
    private let authNumberField: IFType1 = {
        
       let textField = IFType1(
            placeHolderText: "",
        submitButtonText: "확인",
        keyboardType: .numberPad
       )
        
        textField.idleTextField.isCompleteImageAvailable = false
        
        return textField
    }()
        
    private let authSuccessText: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.textString = "* 인증이 완료되었습니다."
        label.textAlignment = .left
        label.attrTextColor = DSKitAsset.Colors.gray300.color
        label.isHidden = true
        return label
    }()
    
    private let buttonContainer = PrevOrNextContainer()
    
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
    
    override func viewDidLoad() {
        
        view.backgroundColor = .clear
    }
    
    private func setAppearance() {
        
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        
        [
            processTitle,
            phoneNumberLabel,
            phoneNumberField,
            authNumberLabel,
            authNumberField,
            authSuccessText,
            buttonContainer,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            phoneNumberLabel.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            phoneNumberField.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 6),
            phoneNumberField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            phoneNumberField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            authNumberLabel.topAnchor.constraint(equalTo: phoneNumberField.bottomAnchor, constant: 28),
            authNumberLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            authNumberLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            authNumberField.topAnchor.constraint(equalTo: authNumberLabel.bottomAnchor, constant: 6),
            authNumberField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            authNumberField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            authSuccessText.topAnchor.constraint(equalTo: authNumberField.bottomAnchor, constant: 4),
            authSuccessText.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            authSuccessText.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
        
    private func initialUISettuing() {
        
        // Initial setting
        // - 휴대번호 '인증 요청' 버튼 비활성화
        phoneNumberField.button.setEnabled(false)
        
        // - 인증번호 입력및 '확인'버튼 비활성화
        authNumberField.idleTextField.setEnabled(false)
        authNumberField.button.setEnabled(false)
        
        // - CTA버튼 비활성화
        buttonContainer.nextButton.setEnabled(false)
    }
    
    public func setObservable() {
        // MARK: Input
        let input = viewModel.input
        
        // 현재 입력중인 정보 전송
        phoneNumberField.idleTextField.textField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingPhoneNumber)
            .disposed(by: disposeBag)
        
        authNumberField.idleTextField.textField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingAuthNumber)
            .disposed(by: disposeBag)
        
        // 인증, 확인 버튼이 눌린 경우
        phoneNumberField
            .eventPublisher
            .map { _ in () }
            .bind(to: input.requestAuthForPhoneNumber)
            .disposed(by: disposeBag)
        
        authNumberField
            .eventPublisher
            .map { _ in () }
            .bind(to: input.requestValidationForAuthNumber)
            .disposed(by: disposeBag)
        
        // MARK: Output
        let output = viewModel.output
        
        // 입력중인 전화번호가 특정 조건(ex: 입력길이)을 만족한 경우 '인증'버튼 활성화
        output
            .canSubmitPhoneNumber?
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                
                guard let self else { return }
                
                phoneNumberField.button.setEnabled($0)
            })
            .disposed(by: disposeBag)
        
        // 입력중인 인증번호가 특정 조건(ex: 입력길이)을 만족한 경우 '확인'버튼 활성화
        output
            .canSubmitAuthNumber?
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in self?.authNumberField.button.setEnabled($0) })
            .disposed(by: disposeBag)
        
        // 휴대전화 인증의 시작
        output
            .phoneNumberValidation?
            .drive(onNext: { [weak self] _ in
                self?.activateAuthNumberField()
            })
            .disposed(by: disposeBag)
        
        // 인증번호 인증 성공여부
        output
            .authNumberValidation?
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                self?.onAuthNumberValidationSuccess()
            })
            .disposed(by: disposeBag)
        
        // MARK: ViewController한정 로직
        // CTA버튼 클릭시 화면전환
        buttonContainer.nextBtnClicked
            .asObservable()
            .bind(to: input.nextButtonClicked)
            .disposed(by: disposeBag)
        
        buttonContainer.prevBtnClicked
            .asObservable()
            .bind(to: input.prevButtonClicked)
            .disposed(by: disposeBag)
    }
}

extension ValidatePhoneNumberViewController {
    
    func activateAuthNumberField() {
        
        // 인증 텍스트 필드 활성화
        authNumberField.idleTextField.setEnabled(true)
        authNumberField.idleTextField.createTimer()
        authNumberField.idleTextField.startTimer(minute: 5, seconds: 0)
    }
    
    func onAuthNumberValidationSuccess() {
        
        // 입력과 관려된 필드와 버튼 비활성화
        phoneNumberField.idleTextField.setEnabled(false)
        phoneNumberField.button.setEnabled(false)
        authNumberField.idleTextField.setEnabled(false)
        authNumberField.button.setEnabled(false)
        
        // 타이머 비활성화
        authNumberField.idleTextField.removeTimer()
        
        // 인증 완료 텍스트
        authSuccessText.isHidden = false
        
        // CTA버튼 활성화
        buttonContainer.nextButton.setEnabled(true)
    }
}
