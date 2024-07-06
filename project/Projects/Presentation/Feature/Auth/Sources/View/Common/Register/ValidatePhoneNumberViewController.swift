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
    
    var phoneNumber: Observable<String>? { get set }
    var phoneNumberAuthNumber: Observable<String>? { get set }
}

public protocol AuthPhoneNumberOutputable {
    
    var startAuth: PublishSubject<String>? { get set }
}

class ValidatePhoneNumberViewController<T: ViewModelType>: DisposableViewController
where 
    T.Input: AuthPhoneNumberInputable & CTAButtonEnableInputable,
    T.Output: AuthPhoneNumberOutputable & CTAButtonEnableOutPutable {
    
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
        
        var input = viewModel.input
        
        // '인증'버튼 클릭시 입력중이된 텍스트 필드값 전송
        input.phoneNumber = phoneNumberField.button.eventPublisher.map({ [weak self] _ in
            self?.phoneNumberField.textField.textField.text ?? ""
        }).asObservable()
        
        // '확인'버튼 클릭시 입력중이된 텍스트 필드값 전송
        input.phoneNumberAuthNumber = authNumberField.button.eventPublisher.map({ [weak self] _ in
            self?.authNumberField.textField.textField.text ?? ""
        }).asObservable()
        
        let output = viewModel.transform(input: input)
        
        // 휴대번호 인증시작
        output
            .startAuth?
            .subscribe(onNext: { [weak self] authingNumber in
                
                printIfDebug("☑️ \(authingNumber)의 인증을 시작합니다.")
                
                // 인증 텍스트 필드 활성화
                self?.authNumberField.textField.setEnabled(true)
                self?.authNumberField.textField.createTimer()
                self?.authNumberField.textField.startTimer(minute: 5, seconds: 0)
            })
            .disposed(by: disposeBag)
        
        // 휴대번호가 입력창에 입력이 있을 경우 '인증'버튼을 활성화
        phoneNumberField.textField
            .eventPublisher
            .subscribe(onNext: { [weak self] phoneNumber in
                
                self?.phoneNumberField.button.setEnabled(phoneNumber.count >= 10)
            })
            .disposed(by: disposeBag)
        
        // 인증번호 입력창에 입력이 있을 경우 '확인'버튼을 활성화
        authNumberField.textField
            .eventPublisher
            .subscribe(onNext: { [weak self] phoneNumber in
                
                self?.authNumberField.button.setEnabled(!phoneNumber.isEmpty)
            })
            .disposed(by: disposeBag)
        
        // 인증 성공여부 획득
        output
            .ctaButtonEnabled?
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                
                if $0 {
                    // 인증번호 인증성공
                    
                    // 인증 성공으로 모든 버튼 비활성화
                    self?.phoneNumberField.textField.setEnabled(false)
                    self?.phoneNumberField.button.setEnabled(false)
                    self?.authNumberField.textField.setEnabled(false)
                    self?.authNumberField.button.setEnabled(false)
                    
                    // 타이머 비활성화
                    self?.authNumberField.textField.removeTimer()
                    
                    // 인증 완료 텍스트
                    self?.authSuccessText.isHidden = false
                }
                
                self?.ctaButton.setEnabled($0)
            })
            .disposed(by: disposeBag)
        
        
        
        // CTA버튼 클릭시
        ctaButton
            .eventPublisher
            .emit { [weak self] _ in
                
                self?.coordinator?.next()
            }
            .disposed(by: disposeBag)
    }
    
    func cleanUp() {
        
    }
}
