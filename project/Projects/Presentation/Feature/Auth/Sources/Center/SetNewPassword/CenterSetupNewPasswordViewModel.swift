//
//  CenterSetupNewPasswordViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/17/24.
//

import Domain
import PresentationCore
import BaseFeature
import Core

import RxSwift
import RxCocoa

class CenterSetupNewPasswordViewModel: BaseViewModel, ViewModelType {
    
    // Injected
    @Injected var authUseCase: AuthUseCase
    @Injected var inputValidationUseCase: AuthInputValidationUseCase
    
    // Navigation
    var presentNextPage: (() -> ())!
    var presentPrevPage: (() -> ())!
    var presentCompleteAndDismiss: (() -> ())!
    
    var input: Input = .init()
    var output: Output = .init()
    
    // State
    private var validPassword: String?
    private var authenticatedPhoneNumebr: String?
    
    override init() {
        
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
            disposeBag: disposeBag) { [weak self] phoneNumber in
                // 🚀 상태추적 🚀
                self?.authenticatedPhoneNumebr = phoneNumber
            }
        
        let changePasswordResult = input.changePasswordButtonClicked
            .compactMap({ [weak self] _ -> (String, String)? in
                
                guard let phoneNumber = self?.authenticatedPhoneNumebr, let validPassword = self?.validPassword else {
                    return nil
                }
                
                return (phoneNumber, validPassword)
            })
            .flatMap { [authUseCase] (phoneNumber, validPassword) in
                
                authUseCase
                    .setNewPassword(phoneNumber: phoneNumber, password: validPassword)
            }
            .share()
        
        changePasswordResult
            .unretained(self)
            .subscribe(onNext: { (obj, result) in
                
                switch result {
                case .success:
                    obj.presentCompleteAndDismiss()
                case .failure(let error):
                    self.alert.onNext(.init(title: "비밀번호 변경 실패", message: error.message))
                }
            })
            .disposed(by: disposeBag)
        
        input.alert
            .subscribe(onNext: { [weak self] alertVO in
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
        
        // MARK: 화면 페이지네이션
        input
            .nextButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentNextPage()
            })
            .disposed(by: disposeBag)
        
        input
            .prevButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentPrevPage()
            })
            .disposed(by: disposeBag)
    }
}

extension CenterSetupNewPasswordViewModel {
    
    class Input {
        
        // 화면 전환
        public var nextButtonClicked: PublishSubject<Void> = .init()
        public var prevButtonClicked: PublishSubject<Void> = .init()
        public var completeButtonClicked: PublishSubject<Void> = .init()
        
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
        public var alert: PublishSubject<DefaultAlertContentVO> = .init()
    }
    
    class Output {
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // Password
        public var passwordValidation: Driver<PasswordValidationState>?
        
        public var loginSuccess: Driver<Void>?
    }
}

// Auth phoneNumber
extension CenterSetupNewPasswordViewModel.Input: AuthPhoneNumberInputable { }
extension CenterSetupNewPasswordViewModel.Output: AuthPhoneNumberOutputable { }

extension CenterSetupNewPasswordViewModel.Input: SetPasswordInputable { }
extension CenterSetupNewPasswordViewModel.Output: SetPasswordOutputable { }

extension CenterSetupNewPasswordViewModel.Input: ChangePasswordSuccessInputable { }
extension CenterSetupNewPasswordViewModel.Input: PageProcessInputable { }
