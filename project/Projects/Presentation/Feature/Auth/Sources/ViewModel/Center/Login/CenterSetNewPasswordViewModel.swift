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
import BaseFeature

public class CenterSetNewPasswordViewModel: BaseViewModel, ViewModelType {
    
    // Init
    let authUseCase: AuthUseCase
    let inputValidationUseCase: AuthInputValidationUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    // State
    private var validPassword: String?
    
    public init(
        authUseCase: AuthUseCase,
        inputValidationUseCase: AuthInputValidationUseCase) {
            self.authUseCase = authUseCase
            self.inputValidationUseCase = inputValidationUseCase
            
            super.init()
            
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
                useCase: inputValidationUseCase,
                disposeBag: disposeBag
            ) { _ in }
            
            let changePasswordResult = input.changePasswordButtonClicked
                .flatMap { [weak self] _ in
                    
                    printIfDebug("변경 요청 비밀번호 \(self?.validPassword ?? "")")
                    
                    // TODO: 비밀번호 변경 API 연동
                    // 이벤트 전송
                    return Single.just(Result<Void, HTTPResponseException>.success(()))
                }
                .share()
            
            output.changePasswordValidation = changePasswordResult
                .map { result in
                    switch result {
                    case .success:
                        printIfDebug("비밀번호 변경 성공")
                        return true
                    case .failure(let error):
                        printIfDebug("비밀번호 변경 실패")
                        return false
                    }
                }
                .asDriver(onErrorJustReturn: false)
        }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

public extension CenterSetNewPasswordViewModel {
    
    class Input {
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // Password
        public var editingPasswords: PublishRelay<(pwd: String, cpwd: String)> = .init()
        
        // Change password
        public var changePasswordButtonClicked: PublishRelay<Void> = .init()
        
        // Alert
        public var alert: PublishSubject<Entity.DefaultAlertContentVO> = .init()
    }
    
    class Output {
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // Password
        public var passwordValidation: Driver<PasswordValidationState>?
        
        // Change password
        public var changePasswordValidation: Driver<Bool>?
    }
}

// Auth phoneNumber
extension CenterSetNewPasswordViewModel.Input: AuthPhoneNumberInputable { }
extension CenterSetNewPasswordViewModel.Output: AuthPhoneNumberOutputable { }

extension CenterSetNewPasswordViewModel.Input: SetPasswordInputable { }
extension CenterSetNewPasswordViewModel.Output: SetPasswordOutputable { }

extension CenterSetNewPasswordViewModel.Input: ChangePasswordSuccessInputable { }
extension CenterSetNewPasswordViewModel.Output: ChangePasswordSuccessOutputable { }
