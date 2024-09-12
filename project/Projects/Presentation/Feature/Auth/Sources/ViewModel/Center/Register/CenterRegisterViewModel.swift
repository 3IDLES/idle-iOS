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
import BaseFeature

public class CenterRegisterViewModel: BaseViewModel, ViewModelType {
    
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
            
            super.init()
            
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
                useCase: inputValidationUseCase,
                disposeBag: disposeBag
            ) { [weak self] authedPhoneNumber in
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
            
            input.alert
                .bind(to: self.alert)
                .disposed(by: disposeBag)
        }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

// MARK: ViewModel input output
extension CenterRegisterViewModel {
    
    public class Input {
        
        // CTA 버튼 클릭시
        public var ctaButtonClicked: PublishRelay<Void> = .init()
        
        // 이름입력
        public var editingName: PublishRelay<String> = .init()
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 사업자 번호 입력
        public var editingBusinessNumber: BehaviorRelay<String> = .init(value: "")
        public var requestBusinessNumberValidation: PublishRelay<Void> = .init()
        
        // Id
        public var editingId: BehaviorRelay<String> = .init(value: "")
        public var requestIdDuplicationValidation: PublishRelay<String> = .init()
        
        // Password
        public var editingPasswords: PublishRelay<(pwd: String, cpwd: String)> = .init()
        
        // Alert
        public var alert: PublishSubject<DefaultAlertContentVO> = .init()
    }
    
    public class Output {
        
        // 이름 입력
        public var nameValidation: Driver<Bool>?
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // 사업자 번호 입력
        public var canSubmitBusinessNumber: Driver<Bool>?
        public var businessNumberVO: Driver<BusinessInfoVO>?
        public var businessNumberValidationFailure: Driver<Void>?
        
        // Id
        public var canCheckIdDuplication: Driver<Bool>?
        public var idDuplicationValidation: Driver<Bool>?
        
        // Password
        public var passwordValidation: Driver<PasswordValidationState>?
        
        // Register success
        public var registerValidation: Driver<Void>?
        public var loginValidation: Driver<Void>?
    }
}

extension CenterRegisterViewModel {
    
    func registerInOut() {
        // MARK: 최종 회원가입 버튼
        let registerValidation = input
            .ctaButtonClicked
            .flatMap { [unowned self] _ in
                self.authUseCase
                    .registerCenterAccount(registerState: self.stateObject)
            }
            .share()
        
        let loginResult = registerValidation
            .compactMap { $0.value }
            .map { [unowned self] _ in
                printIfDebug("[\(#function)] ✅ 회원가입 성공 \n 가임정보 \(stateObject.description)")
                return (id: stateObject.id, password: stateObject.password)
            }
            .flatMap { [authUseCase] (id, pw) in
                printIfDebug("[\(#function)] 로그인 실행")
                return authUseCase
                    .loginCenterAccount(id: id, password: pw)
            }
            .map { [weak self] _ in
                // 로그인 결과무시
                self?.stateObject.clear()
                return ()
            }
        output.registerValidation = loginResult.asDriver(onErrorJustReturn: ())
        
        let registrationFailureAlert = registerValidation
            .compactMap { $0.error }
            .map { error in
                printIfDebug("❌ 회원가입 실패: \(error.message)")
                return DefaultAlertContentVO(
                    title: "회원가입 실패",
                    message: error.message
                )
            }
        
        registrationFailureAlert
            .subscribe(self.alert)
            .disposed(by: disposeBag)
    }
}

extension CenterRegisterViewModel {
    
    func validateBusinessNumberInOut() {
        // MARK: 사업자 번호 입력
        output.canSubmitBusinessNumber = input
            .editingBusinessNumber
            .map { [unowned self] businessNumber in
                self.inputValidationUseCase.checkBusinessNumberIsValid(businessNumber: businessNumber)
            }
            .asDriver(onErrorJustReturn: false)
        
        let businessNumberValidationResult = input
            .requestBusinessNumberValidation
            .compactMap { $0 }
            .flatMap { [weak self, input, inputValidationUseCase] _ in
                
                // 로딩 시작
                self?.showLoading.onNext(())
                
                let businessNumber = input.editingBusinessNumber.value
                let formatted = AuthInOutStreamManager.formatBusinessNumber(businessNumber: businessNumber)
                printIfDebug("[CenterRegisterViewModel] 사업자 번호 인증 요청: \(formatted)")
                return inputValidationUseCase
                    .requestBusinessNumberAuthentication(businessNumber: formatted)
            }
            .share()
        
        businessNumberValidationResult
            .subscribe(onNext: { [weak self] _ in
                // 로딩 종료
                self?.dismissLoading.onNext(())
            })
            .disposed(by: disposeBag)
        
        
        output.businessNumberVO = businessNumberValidationResult
            .compactMap { $0.value }
            .map { [stateObject] (businessNumber, infoVO) in
                printIfDebug("✅ 사업자번호 검색 성공")
                // 🚀 상태추적 🚀
                stateObject.businessNumber = businessNumber
                return infoVO
            }
            .asDriver(onErrorJustReturn: .onError)
        
        let searchFailure = businessNumberValidationResult
            .compactMap { $0.error }
        
        output.businessNumberValidationFailure = searchFailure
            .map { error in
                printIfDebug("❌ 사업자번호 검색실패 \n 에러내용: \(error.message)")
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
        searchFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "사업자 번호 조회 오류",
                    message: error.message
                )
            }
            .subscribe(onNext: { [weak self] alertVO in
                
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
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
extension CenterRegisterViewModel.Input: SetPasswordInputable { }
extension CenterRegisterViewModel.Output: SetIdOutputable { }
extension CenterRegisterViewModel.Output: SetPasswordOutputable { }

// Register
extension CenterRegisterViewModel.Output: RegisterValidationOutputable { }
