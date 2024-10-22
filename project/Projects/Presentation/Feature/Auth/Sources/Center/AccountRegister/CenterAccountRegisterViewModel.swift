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

class CenterAccountRegisterViewModel: BaseViewModel, ViewModelType {
    
    // Injected
    @Injected var inputValidationUseCase: AuthInputValidationUseCase
    @Injected var authUseCase: AuthUseCase
    
    var presentNextPage: (() -> ())?
    var presentPrevPage: (() -> ())?
    var presentCompleteScreen: (() -> ())?
    var presentAlert: ((DefaultAlertObject) -> ())?
    
    // Input은 모든 ViewController에서 공유한다. (다만, 각가의 ViewController의 Input프로토콜에 의해 제한된다.)
    let input = Input()
    let output = Output()
    
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
        
        
        
       
        
//        AuthInOutStreamManager.idInOut(
//            input: input,
//            output: output,
//            useCase: inputValidationUseCase) { [weak self] validId in
//                // 🚀 상태추적 🚀
//                self?.stateObject.id = validId
//            }
//        
//        AuthInOutStreamManager.passwordInOut(
//            input: input,
//            output: output,
//            useCase: inputValidationUseCase) { [weak self] validPassword in
//                // 🚀 상태추적 🚀
//                self?.stateObject.password = validPassword
//            }
        
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
                obj.presentNextPage?()
            })
            .disposed(by: disposeBag)
        
        input
            .prevButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentPrevPage?()
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}


// MARK: Id & Password validation
extension CenterAccountRegisterViewModel {
    
    func idAndPasswordValidationBinding() {
        
        // ID
        output.idValidationResult = input
            .editingId
            .unretained(self)
            .map { (vm, id) in
                vm.inputValidationUseCase.checkIdIsValid(id: id)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let idDuplicationCheckResult = input
            .isIdDuplicatedButtonPressed
            .withLatestFrom(input.editingId)
            .unretained(self)
            .flatMap { (vm, id) in
                
                printIfDebug("[CenterRegisterViewModel] 중복성 검사 대상 id: \(id)")
                
                #if DEBUG
                // 디버그시 아이디 중복체크 미실시
                print("✅ 디버그모드에서 아이디 중복검사 미실시")
                // ☑️ 상태추적 ☑️
                stateTracker(id)
                return Single.just(Result<Void, DomainError>.success(()))
                #endif
                
                return vm.inputValidationUseCase.requestCheckingIdDuplication(id: id)
            }
            .share()
        
        output.idDuplicationCheckResult = idDuplicationCheckResult
            .map({ result in
                switch result {
                case .success:
                    return true
                case .failure:
                    return false
                }
            })
            .asDriver(onErrorDriveWith: .never())
        
        let idDuplicationFailure = idDuplicationCheckResult.compactMap { $0.error }
        
        idDuplicationFailure
            .unretained(self)
            .subscribe(onNext: { (vm, error) in
                
                let alertObject: DefaultAlertObject = .init()
                alertObject.setTitle("아이디 중복검사 실패")
                alertObject.setDescription(error.message)
                
                vm.presentAlert?(alertObject)
            })
            .disposed(by: disposeBag)
        
        
        // Passwords
        output.passwordValidationState = Observable
            .combineLatest(
                input.editingPassword,
                input.checkingPassword
            )
            .unretained(self)
            .map { (vm, passwords) in
                
                let (editing, checking) = passwords
                
                let stateObject: PasswordValidationState = vm.inputValidationUseCase
                    .checkPasswordIsValid(password: editing)
                
                stateObject.setEqualState(state: editing == checking)
                
                return stateObject
            }
            .asDriver(onErrorDriveWith: .never())
    }
}

// MARK: ViewModel input output
extension CenterAccountRegisterViewModel {
    
    class Input {
        
        // CTA 버튼 클릭시
        var nextButtonClicked: PublishSubject<Void> = .init()
        var prevButtonClicked: PublishSubject<Void> = .init()
        var completeButtonClicked: PublishSubject<Void> = .init()
        
        // 이름입력
        public var editingName: PublishRelay<String> = .init()
        
        // 전화번호 입력
        var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 사업자 번호 입력
        var editingBusinessNumber: BehaviorRelay<String> = .init(value: "")
        var requestBusinessNumberValidation: PublishRelay<Void> = .init()
        
        // Id
        var editingId: PublishSubject<String> = .init()
        var isIdDuplicatedButtonPressed: PublishSubject<Void> = .init()
        
        // Password
        var editingPassword: PublishSubject<String> = .init()
        var checkingPassword: BehaviorSubject<String> = .init(value: "")
        
        // Alert
        var alert: PublishSubject<DefaultAlertContentVO> = .init()
    }
    
    class Output {
        
        // 이름 입력
        public var nameValidation: Driver<Bool>?
        
        // 전화번호 입력
        var canSubmitPhoneNumber: Driver<Bool>?
        var canSubmitAuthNumber: Driver<Bool>?
        var phoneNumberValidation: Driver<Bool>?
        var authNumberValidation: Driver<Bool>?
        
        // 사업자 번호 입력
        var canSubmitBusinessNumber: Driver<Bool>?
        var businessNumberVO: Driver<BusinessInfoVO>?
        var businessNumberValidationFailure: Driver<Void>?
        
        // Id
        var idValidationResult: Driver<Bool> = .empty()
        var idDuplicationCheckResult: Driver<Bool> = .empty()
        
        // Password
        var passwordValidationState: Driver<PasswordValidationState> = .empty()
        
        // Register success
        var loginSuccess: Driver<Void>?
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
                obj.presentCompleteScreen?()
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
extension CenterAccountRegisterViewModel.Input: SetIdAndPasswordInputable { }
extension CenterAccountRegisterViewModel.Output: SetIdAndPasswordOutputable { }

