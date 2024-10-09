//
//  CenterAccountRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import PresentationCore
import BaseFeature
import Domain
import Core

import RxSwift
import RxCocoa

public class CenterAccountRegisterViewModel: BaseViewModel, ViewModelType {
    
    // Injected
    @Injected var inputValidationUseCase: AuthInputValidationUseCase
    @Injected var authUseCase: AuthUseCase
    
    var presentNextPage: (() -> ())!
    var presentPrevPage: (() -> ())!
    var presentCompleteScreen: (() -> ())!
    
    // Input은 모든 ViewController에서 공유한다. (다만, 각가의 ViewController의 Input프로토콜에 의해 제한된다.)
    public let input = Input()
    public let output = Output()
    
    internal let stateObject = CenterRegisterState()
    
    public override init() {
        
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
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

// MARK: ViewModel input output
extension CenterAccountRegisterViewModel {
    
    public class Input {
        
        // CTA 버튼 클릭시
        public var nextButtonClicked: PublishSubject<Void> = .init()
        public var prevButtonClicked: PublishSubject<Void> = .init()
        public var completeButtonClicked: PublishSubject<Void> = .init()
        
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
        public var loginSuccess: Driver<Void>?
    }
}

extension CenterAccountRegisterViewModel {
    
    func registerInOut() {
        // MARK: 최종 회원가입 버튼
        let registerResult = input
            .completeButtonClicked
            .flatMap { [unowned self] _ in
                self.authUseCase
                    .registerCenterAccount(registerState: self.stateObject)
            }
            .share()
        
        let registerSuccess = registerResult.compactMap { $0.value }
        let registerFailure = registerResult.compactMap { $0.error }
        
        let loginResult = registerSuccess
            .map { [unowned self] _ in
                printIfDebug("[\(#function)] ✅ 회원가입 성공 \n 가임정보 \(stateObject.description)")
                return (id: stateObject.id, password: stateObject.password)
            }
            .flatMap { [authUseCase] (id, pw) in
                printIfDebug("[\(#function)] 로그인 실행")
                return authUseCase
                    .loginCenterAccount(id: id, password: pw)
            }
        
        let loginSuccess = loginResult.compactMap { $0.value }
        let loginFailure = loginResult.compactMap { $0.error }
        
        loginSuccess
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentCompleteScreen()
            })
            .disposed(by: disposeBag)
        
        let registrationFailureAlert = Observable
            .merge(registerFailure, loginFailure)
            .map { error in
                printIfDebug("❌ 회원가입 실패: \(error.message)")
                return DefaultAlertContentVO(
                    title: "회원가입 실패",
                    message: error.message
                )
            }
        
        registrationFailureAlert
            .subscribe(onNext: { [weak self] alertVO in
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
    }
}

extension CenterAccountRegisterViewModel {
    
    func validateBusinessNumberInOut() {
        // MARK: 사업자 번호 입력
        output.canSubmitBusinessNumber = input
            .editingBusinessNumber
            .map { [unowned self] businessNumber in
                self.inputValidationUseCase.checkBusinessNumberIsValid(businessNumber: businessNumber)
            }
            .asDriver(onErrorJustReturn: false)
        
        let requestingBusinessNumber = input
            .requestBusinessNumberValidation
            .withLatestFrom(input.editingBusinessNumber)
            .map { unformedNumber in
                let formatted = AuthInOutStreamManager.formatBusinessNumber(businessNumber: unformedNumber)
                return formatted
            }
        
        let businessNumberValidationResult = requestingBusinessNumber
            .compactMap { $0 }
            .flatMap { [weak self, inputValidationUseCase] businessNumber in
                
                // 로딩 시작
                self?.showLoading.onNext(())
                
                return inputValidationUseCase
                    .requestBusinessNumberAuthentication(businessNumber: businessNumber)
            }
            .share()
        
        businessNumberValidationResult
            .subscribe(onNext: { [weak self] _ in
                // 로딩 종료
                self?.dismissLoading.onNext(())
            })
            .disposed(by: disposeBag)
        
        let businessNumberValidationSuccess = businessNumberValidationResult
            .compactMap { $0.value }
        
        output.businessNumberVO = Observable
            .combineLatest(requestingBusinessNumber, businessNumberValidationSuccess)
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
extension CenterAccountRegisterViewModel.Input: PageProcessInputable { }

// Enter name
extension CenterAccountRegisterViewModel.Input: EnterNameInputable { }
extension CenterAccountRegisterViewModel.Output: EnterNameOutputable { }

// Auth phoneNumber
extension CenterAccountRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension CenterAccountRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Auth Business owner
extension CenterAccountRegisterViewModel.Input: AuthBusinessOwnerInputable { }
extension CenterAccountRegisterViewModel.Output: AuthBusinessOwnerOutputable { }

// Id & Password
extension CenterAccountRegisterViewModel.Input: SetIdInputable { }
extension CenterAccountRegisterViewModel.Input: SetPasswordInputable { }
extension CenterAccountRegisterViewModel.Output: SetIdOutputable { }
extension CenterAccountRegisterViewModel.Output: SetPasswordOutputable { }

