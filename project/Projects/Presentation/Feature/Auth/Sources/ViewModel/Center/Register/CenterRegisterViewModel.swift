//
//  CenterRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore
import UseCaseInterface
import Entity

public class CenterRegisterViewModel: ViewModelType {
    
    // UseCase
    public let inputValidationUseCase: AuthInputValidationUseCase
    public let authUseCase: AuthUseCase
    
    // Input은 모든 ViewController에서 공유한다. (다만, 각가의 ViewController의 Input프로토콜에 의해 제한된다.)
    public let input = Input()
    public let output = Output()
    
    internal let stateObject = CenterRegisterState()
        
    public init(
        inputValidationUseCase: AuthInputValidationUseCase,
        authUseCase: AuthUseCase) {
            self.inputValidationUseCase = inputValidationUseCase
            self.authUseCase = authUseCase
            
            AuthInOutStreamManager.enterNameInOut(
                input: input,
                output: output,
                useCase: inputValidationUseCase) { [weak self] validName in
                    // 🚀 상태추적 🚀
                    self?.stateObject.name = validName
                }
            
            AuthInOutStreamManager.validatePhoneNumberInOut(
                input: input,
                output: output,
                useCase: inputValidationUseCase) { [weak self] authedPhoneNumber in
                    // 🚀 상태추적 🚀
                    self?.stateObject.phoneNumber = authedPhoneNumber
                }
            
            // viewmodel native
            registerInOut()
            validateBusinessNumberInOut()
            
            
            AuthInOutStreamManager.idInOut(
                input: input,
                output: output,
                useCase: inputValidationUseCase) { [weak self] validId in
                    // 🚀 상태추적 🚀
                    self?.stateObject.id = validId
                }
            
            AuthInOutStreamManager.passwordInOut(
                input: input,
                output: output,
                useCase: inputValidationUseCase) { [weak self] validPassword in
                    // 🚀 상태추적 🚀
                    self?.stateObject.password = validPassword
                }
        }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

// MARK: ViewModel input output
extension CenterRegisterViewModel {
    
    public class Input {
        
        // CTA 버튼 클릭시
        public var ctaButtonClicked: PublishRelay<Void?> = .init()
        
        // 이름입력
        public var editingName: PublishRelay<String?> = .init()
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 사업자 번호 입력
        public var editingBusinessNumber: PublishRelay<String?> = .init()
        public var requestBusinessNumberValidation: PublishRelay<String?> = .init()
        
        // Id
        public var editingId: PublishRelay<String?> = .init()
        public var requestIdDuplicationValidation: PublishRelay<String?> = .init()
        
        // Password
        public var editingPassword: PublishRelay<(pwd: String, cpwd: String)?> = .init()
    }
    
    public class Output {
        
        // 이름 입력
        public var nameValidation: PublishSubject<(isValid: Bool, name: String)> = .init()
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // 사업자 번호 입력
        public var canSubmitBusinessNumber: PublishRelay<Bool?> = .init()
        public var businessNumberValidation: PublishRelay<BusinessInfoVO?> = .init()
        
        // Id
        public var canCheckIdDuplication: PublishRelay<Bool?> = .init()
        public var idDuplicationValidation: PublishRelay<String?> = .init()
        
        // Password
        public var passwordValidation: PublishRelay<PasswordValidationState?> = .init()
        
        // Register success
        public var registerValidation: PublishRelay<Bool?> = .init()
        
        // Alert
        public var alert: Driver<DefaultAlertContentVO>?
    }
}

extension CenterRegisterViewModel {
    
    func registerInOut() {
        // MARK: 최종 회원가입 버튼
        let registerValidation = input
            .ctaButtonClicked
            .compactMap({ $0 })
            .flatMap { [unowned self] _ in
                self.authUseCase
                    .registerCenterAccount(registerState: self.stateObject)
            }
            .share()
        
        _ = registerValidation
            .compactMap { $0.value }
            .map { [unowned self] _ in
                printIfDebug("[CenterRegisterViewModel] ✅ 회원가입 성공 \n 가임정보 \(self.stateObject.description)")
                self.stateObject.clear()
                self.output.registerValidation.accept(true)
            }
        
        _ = registerValidation
            .compactMap { $0.error }
            .map({ error in
                printIfDebug("❌ 회원가입 실패: \(error.message)")
                self.output.registerValidation.accept(false)
            })
    }
}

extension CenterRegisterViewModel {
    
    func validateBusinessNumberInOut() {
        // MARK: 사업자 번호 입력
        _ = input
            .editingBusinessNumber
            .compactMap { $0 }
            .map({ [unowned self] businessNumber in
                self.inputValidationUseCase.checkBusinessNumberIsValid(businessNumber: businessNumber)
            })
            .bind(to: output.canSubmitBusinessNumber)
        
        let businessNumberValidationResult = input
            .requestBusinessNumberValidation
            .compactMap { $0 }
            .flatMap({ [unowned self] businessNumber in
                let formatted = AuthInOutStreamManager.formatBusinessNumber(businessNumber: businessNumber)
                printIfDebug("[CenterRegisterViewModel] 사업자 번호 인증 요청: \(formatted)")
                return self.inputValidationUseCase
                    .requestBusinessNumberAuthentication(businessNumber: formatted)
            })
            .share()
        
        _ = businessNumberValidationResult
            .compactMap { $0.value }
            .map({ [weak self] (businessNumber, infoVO) in
                printIfDebug("✅ 사업자번호 검색 성공")
                // 🚀 상태추적 🚀
                self?.stateObject.businessNumber = businessNumber
                self?.output.businessNumberValidation.accept(infoVO)
            })
        
        
        _ = businessNumberValidationResult
            .compactMap { $0.error }
            .map({ [weak self] error in
                printIfDebug("❌ 사업자번호 검색실패 \n 에러내용: \(error.message)")
                self?.output.businessNumberValidation.accept(nil)
            })
    }

}


// MARK: Input Validation

// CTAButton
extension CenterRegisterViewModel.Input: CTAButtonEnableInputable { }

// Enter name
extension CenterRegisterViewModel.Input: EnterNameInputable { }
extension CenterRegisterViewModel.Output: EnterNameOutputable { }

// Auth phoneNumber
extension CenterRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension CenterRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Auth Business owner
extension CenterRegisterViewModel.Input: AuthBusinessOwnerInputable { }
extension CenterRegisterViewModel.Output: AuthBusinessOwnerOutputable { }

// Id & Password
extension CenterRegisterViewModel.Input: SetIdInputable { }
extension CenterRegisterViewModel.Output: SetIdOutputable { }
extension CenterRegisterViewModel.Input: SetPasswordInputable { }
extension CenterRegisterViewModel.Output: SetPasswordOutputable { }

// Register
extension CenterRegisterViewModel.Output: RegisterSuccessOutputable { }
