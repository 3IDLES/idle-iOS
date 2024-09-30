//
//  CenterSetNewPasswordViewModel.swift
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

public class CenterSetNewPasswordViewModel: BaseViewModel, ViewModelType {
    
    // Init
    @Injected var authUseCase: AuthUseCase
    @Injected var inputValidationUseCase: AuthInputValidationUseCase
    weak var coordinator: CenterSetNewPasswordCoordinator?
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    // State
    private var validPassword: String?
    private var authenticatedPhoneNumebr: String?
    
    public init(coordinator: CenterSetNewPasswordCoordinator) {
        self.coordinator = coordinator
        
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
            .subscribe(onNext: {
                [weak self] result in
                
                guard let self else { return }
                
                switch result {
                case .success:
                    self.coordinator?
                        .coordinatorDidFinishWithSnackBar(
                            ro: .init(
                                titleText: "비밀번호 변경 성공"
                            )
                        )
                case .failure(let error):
                    self.alert.onNext(
                        .init(
                            title: "비밀번호 변경 실패",
                            message: error.message
                        )
                    )
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
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.next()
            })
            .disposed(by: disposeBag)
        
        input
            .prevButtonClicked
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.prev()
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

public extension CenterSetNewPasswordViewModel {
    
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
extension CenterSetNewPasswordViewModel.Input: AuthPhoneNumberInputable { }
extension CenterSetNewPasswordViewModel.Output: AuthPhoneNumberOutputable { }

extension CenterSetNewPasswordViewModel.Input: SetPasswordInputable { }
extension CenterSetNewPasswordViewModel.Output: SetPasswordOutputable { }

extension CenterSetNewPasswordViewModel.Input: ChangePasswordSuccessInputable { }
extension CenterSetNewPasswordViewModel.Input: PageProcessInputable { }
