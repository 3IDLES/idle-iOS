//
//  WorkerRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore
import UseCaseInterface
import Entity
import BaseFeature

public class WorkerRegisterViewModel: BaseViewModel, ViewModelType {
    
    // UseCase
    public let inputValidationUseCase: AuthInputValidationUseCase
    public let authUseCase: AuthUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    private let stateObject = WorkerRegisterState()
    
    public init(
        inputValidationUseCase: AuthInputValidationUseCase,
        authUseCase: AuthUseCase
    ) {
        self.inputValidationUseCase = inputValidationUseCase
        self.authUseCase = authUseCase
        
        super.init()
        
        setInput()
    }
    
    private func setInput() {
        
        // MARK: 이름 입력
        AuthInOutStreamManager.enterNameInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase) { [weak self] validName in
                // 🚀 상태추적 🚀
                self?.stateObject.name = validName
            }
        
        // MARK: 성별 선택
        output.genderIsSelected = input.selectingGender
            .filter({ $0 != .notDetermined })
            .map { [weak self] gender in
                printIfDebug("선택된 성별: \(gender)")
                self?.stateObject.gender = gender
                return true
            }
            .asDriver(onErrorJustReturn: false)
            
        
        // MARK: 생년월일 입력
        output.edtingBirthYearValidation = input
            .edtingBirthYear
            .map { [unowned self] in
                printIfDebug("입력중인 생년월일: \($0)")
                let isValid = self.validateBirthYear($0)
                if isValid {
                    self.stateObject.birthYear = $0
                }
                return isValid
            }
            .asDriver(onErrorJustReturn: false)
            
        // MARK: 전화번호 입력
        AuthInOutStreamManager.validatePhoneNumberInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase,
            authUseCase: authUseCase,
            disposeBag: disposeBag
        ) { [weak self] authedPhoneNumber in
                // 🚀 상태추적 🚀
                self?.stateObject.phoneNumber = authedPhoneNumber
            }
        
        // MARK: 주소 입력
        // 예외적으로 ViewModel에서 구독처리
        input
            .addressInformation
            .subscribe(onNext: { [stateObject] info in
                stateObject.addressInformation = info
            })
            .disposed(by: disposeBag)
        
        registerInOut()
    }
    
    private func validateBirthYear(_ year: Int) -> Bool {
        let currentYear: Int = Calendar.current.component(.year, from: Date())
        return (1900..<currentYear).contains(year)
    }
    
    private func registerInOut() {
        
        let registerValidation = input
            .ctaButtonClicked
            .compactMap { $0 }
            .flatMap { [authUseCase, stateObject] _ in
                authUseCase.registerWorkerAccount(registerState: stateObject)
            }
            .share()
        
        output.registerValidation = registerValidation
            .compactMap { $0.value }
            .map {
                print("✅ 회원가입 성공")
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
        let failureAlert = registerValidation
            .compactMap { $0.error }
            .map { error in
                print("❌ 회원가입 실패 \n 에러내용: \(error.message)")
                return DefaultAlertContentVO(
                    title: "회원가입 실패",
                    message: error.message
                )
            }
        
        failureAlert
            .subscribe(self.alert)
            .disposed(by: disposeBag)
    }
}

extension WorkerRegisterViewModel {
    
    func formatPhoneNumber(phoneNumber: String) -> String {
        let s1 = phoneNumber.startIndex
        let e1 = phoneNumber.index(s1, offsetBy: 3)
        let s2 = e1
        let e2 = phoneNumber.index(s2, offsetBy: 4)
        let s3 = e2
        let e3 = phoneNumber.index(s3, offsetBy: 4)
       
        let formattedString = [
            phoneNumber[s1..<e1],
            phoneNumber[s2..<e2],
            phoneNumber[s3..<e3]
        ].joined(separator: "-")
        
        return formattedString
    }
}

// MARK: ViewModel input output
extension WorkerRegisterViewModel {
    
    public class Input {
        // CTA 버튼 클릭시
        public var ctaButtonClicked: PublishRelay<Void> = .init()
        
        // 이름입력, 생년월일 입력, 성별 선택
        public var editingName: PublishRelay<String> = .init()
        public var edtingBirthYear: PublishRelay<Int> = .init()
        public var selectingGender: BehaviorRelay<Gender> = .init(value: .notDetermined)
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 주소 입력
        public var addressInformation: PublishRelay<AddressInformation> = .init()
        
        // Alert
        public var alert: PublishSubject<DefaultAlertContentVO> = .init()
    }
    
    public class Output {
        // 이름 입력
        public var nameValidation: Driver<Bool>?
        public var edtingBirthYearValidation: Driver<Bool>?
        
        // 성별
        public var genderIsSelected: Driver<Bool>?
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // 회원가입 성공 여부
        public var registerValidation: Driver<Void>?
        
        // 요양보호사 로그인 성공 여부
        public var loginValidation: Driver<Void>?
    }
}

// CTAButton
extension WorkerRegisterViewModel.Input: CTAButtonEnableInputable { }

// Enter personal info
extension WorkerRegisterViewModel.Input: WorkerPersonalInfoInputable { }
extension WorkerRegisterViewModel.Output: WorkerPersonalInfoOutputable { }

// Auth phoneNumber
extension WorkerRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension WorkerRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Postal code
extension WorkerRegisterViewModel.Input: EnterAddressInputable { }

extension WorkerRegisterViewModel.Output: RegisterValidationOutputable { }
