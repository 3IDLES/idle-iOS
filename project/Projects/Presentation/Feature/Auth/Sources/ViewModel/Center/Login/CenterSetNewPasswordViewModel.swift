//
//  CenterSetNewPasswordViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/17/24.
//

import RxSwift
import RxCocoa
import UseCaseInterface
import Entity
import PresentationCore

public class CenterSetNewPasswordViewModel: ViewModelType {
    
    // Init
    let authUseCase: AuthUseCase
    let inputValidationUseCase: AuthInputValidationUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    var validPassword: String?
    
    public init(
        authUseCase: AuthUseCase,
        inputValidationUseCase: AuthInputValidationUseCase) {
        self.authUseCase = authUseCase
        self.inputValidationUseCase = inputValidationUseCase
            
        setObservable()
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    func setObservable() {
        
        // 비밀번호
        AuthInOutStreamManager.passwordInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase) { [weak self] validPassword in
                // 🚀 상태추적 🚀
                self?.validPassword = validPassword
            }
        
        // 휴대전화 인증
        AuthInOutStreamManager.validatePhoneNumberInOut(
                input: input,
                output: output,
                useCase: inputValidationUseCase) { _ in }
        
        let changePasswordResult = input.changePasswordButtonClicked
            .compactMap { $0 }
            .flatMap { [weak self] _ in
                
                printIfDebug("변경 요청 비밀번호 \(self?.validPassword ?? "")")
                
                // 이벤트 전송
                return Single.just(Result<Void, HTTPResponseException>.success(()))
            }
            .share()
        
        _ = changePasswordResult
            .compactMap { $0.value }
            .map({ [weak self] _ in
                printIfDebug("비밀번호 변경 성공")
                self?.output.changePasswordSuccessValidation.accept(true)
            })
        
        _ = changePasswordResult
            .compactMap { $0.error }
            .map({ [weak self] _ in
                printIfDebug("비밀번호 변경 실패")
                self?.output.changePasswordSuccessValidation.accept(false)
            })
    }
}

public extension CenterSetNewPasswordViewModel {
    
    class Input {
        
        // 전화번호 입력
        public var editingPhoneNumber: PublishRelay<String?> = .init()
        public var editingAuthNumber: PublishRelay<String?> = .init()
        public var requestAuthForPhoneNumber: PublishRelay<String?> = .init()
        public var requestValidationForAuthNumber: PublishRelay<String?> = .init()
        
        // Password
        public var editingPassword: PublishRelay<(pwd: String, cpwd: String)?> = .init()
        
        // Change password
        public var changePasswordButtonClicked: PublishRelay<Void?> = .init()
    }
    
    class Output {
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: PublishRelay<Bool?> = .init()
        public var canSubmitAuthNumber: PublishRelay<Bool?> = .init()
        public var phoneNumberValidation: PublishRelay<Bool?> = .init()
        public var authNumberValidation: PublishRelay<Bool?> = .init()
        
        // Password
        public var passwordValidation: PublishRelay<PasswordValidationState?> = .init()
        
        // Change password
        public var changePasswordSuccessValidation: PublishRelay<Bool?> = .init()
    }
}

// Auth phoneNumber
extension CenterSetNewPasswordViewModel.Input: AuthPhoneNumberInputable { }
extension CenterSetNewPasswordViewModel.Output: AuthPhoneNumberOutputable { }

extension CenterSetNewPasswordViewModel.Input: SetPasswordInputable { }
extension CenterSetNewPasswordViewModel.Output: SetPasswordOutputable { }

extension CenterSetNewPasswordViewModel.Input: ChangePasswordSuccessInputable { }
extension CenterSetNewPasswordViewModel.Output: ChangePasswordSuccessOutputable { }
