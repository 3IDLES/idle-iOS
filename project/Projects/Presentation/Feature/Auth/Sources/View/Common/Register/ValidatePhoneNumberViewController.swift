//
//  ValidatePhoneNumberViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import RxSwift
import DSKit
import PresentationCore

public protocol AuthPhoneNumberInputable {
    
    var editingPhoneNumber: Observable<String>? { get set }
    var editingAuthNumber: Observable<String>? { get set }
    var requestAuthForPhoneNumber: Observable<String>? { get set }
    var requestValidationForAuthNumber: Observable<String>? { get set }
}

public protocol AuthPhoneNumberOutputable {
    
    var canSubmitPhoneNumber: PublishSubject<Bool>? { get set }
    var canSubmitAuthNumber: PublishSubject<Bool>? { get set }
    var phoneNumberValidation: PublishSubject<(isValid: Bool, phoneNumber: String)>? { get set }
    var authNumberValidation: PublishSubject<(isValid: Bool, authNumber: String)>? { get set }
}

class ValidatePhoneNumberViewController<T: ViewModelType>: DisposableViewController
where 
    T.Input: AuthPhoneNumberInputable & CTAButtonEnableInputable,
    T.Output: AuthPhoneNumberOutputable {
    
    var coordinator: Coordinator?
    
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
    private let phoneNumberLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        label.text = "전화번호"
        label.textAlignment = .left
        
        return label
    }()
    private let phoneNumberField: IFType1 = {
        
       let textField = IFType1(
        placeHolderText: "전화번호를 입력해주세요.",
        submitButtonText: "인증"
       )
        
        textField.textField.isCompleteImageAvailable = false
        
        return textField
    }()
    
    // MARK: 인증번호 입력
    private let authNumberLabel: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        label.text = "인증번호"
        label.textAlignment = .left
        
        return label
    }()
    private let authNumberField: IFType1 = {
        
       let textField = IFType1(
        placeHolderText: "",
        submitButtonText: "확인"
       )
        
        textField.textField.isCompleteImageAvailable = false
        
        return textField
    }()
        
    private let authSuccessText: ResizableUILabel = {
        
        let label = ResizableUILabel()
        label.font = DSKitFontFamily.Pretendard.medium.font(size: 12)
        label.text = "인증이 완료되었습니다."
        label.textAlignment = .left
        label.textColor = DSKitAsset.Colors.gray300.color
        label.isHidden = true
        
        return label
    }()
    
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(
        coordinator: Coordinator? = nil,
        viewModel: T
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setAutoLayout()
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
            ctaButton,
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
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func setObservable() {
        
        // Initial setting
        // - 휴대번호 '인증 요청' 버튼 비활성화
        phoneNumberField.button.setEnabled(false)
        
        // - 인증번호 입력및 '확인'버튼 비활성화
        authNumberField.textField.setEnabled(false)
        authNumberField.button.setEnabled(false)
        
        // - CTA버튼 비활성화
        ctaButton.setEnabled(false)
        
        // MARK: Input
        var input = viewModel.input
        
        // 현재 입력중인 정보 전송
        input.editingPhoneNumber = phoneNumberField.textField.eventPublisher.asObservable()
        input.editingAuthNumber = authNumberField.textField.eventPublisher.asObservable()
        
        // 인증, 확인 버튼이 눌린 경우
        input.requestAuthForPhoneNumber = phoneNumberField.eventPublisher.asObservable()
        input.requestValidationForAuthNumber = authNumberField.eventPublisher.asObservable()
        
        // 화면전환 버튼이 눌렸음을 전송
        input.ctaButtonClicked = ctaButton.eventPublisher.asObservable()
        
        // MARK: Output
        let output = viewModel.transform(input: input)
        
        // 입력중인 전화번호가 특정 조건(ex: 입력길이)을 만족한 경우 '인증'버튼 활성화
        output
            .canSubmitPhoneNumber?
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in self?.phoneNumberField.button.setEnabled($0) })
            .disposed(by: disposeBag)
        
        // 입력중인 인증번호가 특정 조건(ex: 입력길이)을 만족한 경우 '확인'버튼 활성화
        output
            .canSubmitAuthNumber?
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in self?.authNumberField.button.setEnabled($0) })
            .disposed(by: disposeBag)
        
        // 휴대전화 인증의 시작
        output
            .phoneNumberValidation?
            .subscribe(onNext: { [weak self] (isValid, phoneNumber) in
                
                if isValid {
                    // 인증이 사작된 경우
                    printIfDebug("☑️ \(phoneNumber)의 인증을 시작합니다.")
                    
                    // 인증 텍스트 필드 활성화
                    self?.authNumberField.textField.setEnabled(true)
                    self?.authNumberField.textField.createTimer()
                    self?.authNumberField.textField.startTimer(minute: 5, seconds: 0)
                }
            })
            .disposed(by: disposeBag)
        
        // 인증번호 인증 성공여부
        output
            .authNumberValidation?
            .subscribe(onNext: { [weak self] (isValid, authNumber) in
                
                if isValid {
                    // 인증번호 인증성공한 경우
                    
                    // 입력과 관려된 필드와 버튼 비활성화
                    self?.phoneNumberField.textField.setEnabled(false)
                    self?.phoneNumberField.button.setEnabled(false)
                    self?.authNumberField.textField.setEnabled(false)
                    self?.authNumberField.button.setEnabled(false)
                    
                    // 타이머 비활성화
                    self?.authNumberField.textField.removeTimer()
                    
                    // 인증 완료 텍스트
                    self?.authSuccessText.isHidden = false
                    
                    // CTA버튼 활성화
                    self?.ctaButton.setEnabled(true)
                }
            })
            .disposed(by: disposeBag)
        
        
        // MARK: ViewController한정 로직
        // CTA버튼 클릭시 화면전환
        ctaButton
            .eventPublisher
            .emit { [weak self] _ in self?.coordinator?.next() }
            .disposed(by: disposeBag)
    }
    
    func cleanUp() {
        
    }
}
