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
    
    private let stateObject = CenterRegisterState()
    
    public init(
        inputValidationUseCase: AuthInputValidationUseCase,
        authUseCase: AuthUseCase) {
            self.inputValidationUseCase = inputValidationUseCase
            self.authUseCase = authUseCase
            
            // MARK: 성함입력
            _ = input
                .editingName
                .compactMap({ $0 })
                .map { [weak self] name in
                    
                    guard let self else { return (false, name) }
                    
                    let isValid = self.inputValidationUseCase.checkNameIsValid(name: name)
                    
                    if isValid {
                        // 🚀 상태추적 🚀
                        self.stateObject.name = name
                    }
                    
                    return (isValid, name)
                }
                .bind(to: output.nameValidation)
            
            // MARK: 전화번호 입력
            _ = input
                .editingPhoneNumber
                .compactMap({ $0 })
                .map({ [unowned self] phoneNumber in
                    printIfDebug("[CenterRegisterViewModel] 전달받은 전화번호: \(phoneNumber)")
                    return self.inputValidationUseCase.checkPhoneNumberIsValid(phoneNumber: phoneNumber)
                })
                .bind(to: output.canSubmitPhoneNumber)
            
            _ = input
                .editingAuthNumber
                .compactMap({ $0 })
                .map({ authNumber in
                    printIfDebug("[CenterRegisterViewModel] 전달받은 인증번호: \(authNumber)")
                    return authNumber.count >= 6
                })
                .bind(to: output.canSubmitAuthNumber)
            
            let phoneNumberAuthRequestResult = input
                .requestAuthForPhoneNumber
                .compactMap({ $0 })
                .flatMap({ [unowned self] number in
                    let formatted = self.formatPhoneNumber(phoneNumber: number)
                    
                    // 상태추적
                    self.stateObject.phoneNumber = formatted
                    
                    #if DEBUG
                    print("✅ 디버그모드에서 번호인증 요청 무조건 통과")
                    return Single.just(Result<Void, InputValidationError>.success(()))
                    #endif
                    
                    return self.inputValidationUseCase.requestPhoneNumberAuthentication(phoneNumber: formatted)
                })
                .share()
            
            _ = phoneNumberAuthRequestResult
                .compactMap { $0.value }
                .map { _ in
                    printIfDebug("✅ 번호로 인증을 시작합니다.")
                    return true
                }
                .bind(to: output.phoneNumberValidation)
            
            _ = phoneNumberAuthRequestResult
                .compactMap { $0.error }
                .map { error in
                    printIfDebug("❌ 인증을 시작할 수 없습니다. \n 에러내용: \(error.message)")
                    return false
                }
                .bind(to: output.phoneNumberValidation)
            
            
            let phoneNumberAuthResult = input.requestValidationForAuthNumber
                .compactMap({ [unowned self] authNumber in
                    if let phoneNumber = self.input.requestAuthForPhoneNumber.value, let authNumber {
                        return (phoneNumber, authNumber)
                    }
                    return nil
                })
                .flatMap { [unowned self] (phoneNumber: String, authNumber: String) in
                    
                    #if DEBUG
                    // 디버그시 인증번호 무조건 통과
                    print("✅ 디버그모드에서 번호인증 무조건 통과")
                    return Single.just(Result<Void, InputValidationError>.success(()))
                    #endif
                    
                    return self.inputValidationUseCase
                        .authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
                }
                .share()
            
            // 번호인증 성공
            _ = phoneNumberAuthResult
                .compactMap { $0.value }
                .map { _ in
                    printIfDebug("✅ 인증성공")
                    return true
                }
                .bind(to: output.authNumberValidation)
        
            // 번호인증 실패
            _ = phoneNumberAuthResult
                .compactMap { $0.error }
                .map { error in
                    printIfDebug("❌ 번호 인증실패 \n 에러내용: \(error.message)")
                    return false
                }
                .bind(to: output.authNumberValidation)
            
        }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    let disposeBag = DisposeBag()
    
    public func transform(input: Input) -> Output {
        
        // MARK: 사업자 번호 입력
        self.input
            .editingBusinessNumber?
            .subscribe(onNext: { [weak self] businessNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 사업자 번호: \(businessNumber)")
                
                guard let self else { return }
                
                let isValid = self.inputValidationUseCase.checkBusinessNumberIsValid(businessNumber: businessNumber)
                self.output.canSubmitBusinessNumber?.onNext(isValid)
            })
            .disposed(by: disposeBag)
        
        self.input
            .requestBusinessNumberValidation?
            .subscribe(onNext: { [weak self] businessNumber in
                
                printIfDebug("[CenterRegisterViewModel] 사업자 번호 인증 요청: \(businessNumber)")
                
                let s1 = businessNumber.startIndex
                let e1 = businessNumber.index(s1, offsetBy: 3)
                let s2 = e1
                let e2 = businessNumber.index(s2, offsetBy: 2)
                let s3 = e2
                let e3 = businessNumber.index(s3, offsetBy: 5)
               
                let formattedString = [
                    businessNumber[s1..<e1],
                    businessNumber[s2..<e2],
                    businessNumber[s3..<e3]
                ].joined(separator: "-")
                
                guard let self else { return }
                
                self.inputValidationUseCase
                    .requestBusinessNumberAuthentication(businessNumber: formattedString)
                    .subscribe { [weak self] result in
                        
                        switch result {
                        case .success(let vo):
                            printIfDebug("✅ \(formattedString)번호 검색 성공")
                            
                            self?.output.businessNumberValidation?.onNext(vo)
                            // 🚀 상태추적 🚀
                            self?.stateObject.businessNumber = formattedString
                        case .failure(let error):
                            
                            printIfDebug("❌ \(formattedString)번호 검색실패 \n 에러내용: \(error.message)")
                            
                            // TODO: 에러처리
                            
                            self?.output.businessNumberValidation?.onNext(nil)
                        }
                    }
                    .disposed(by: self.disposeBag)
                
            })
            .disposed(by: disposeBag)
        
        // MARK: Id & Password
        self.input
            .editingId?
            .subscribe(onNext: { [weak self] id in
                
                printIfDebug("[CenterRegisterViewModel] 입력중인 id: \(id)")
                
                guard let self else { return }
                
                let isValid = self.inputValidationUseCase.checkIdIsValid(id: id)
                
                self.output.canCheckIdDuplication?.onNext(isValid)
            })
            .disposed(by: disposeBag)
        
        // 중복성 검사
        self.input
            .requestIdDuplicationValidation?
            .subscribe(onNext: { [weak self] id in
                
                printIfDebug("[CenterRegisterViewModel] 중복성 검사 대상 id: \(id)")
                
                #if DEBUG
                // 디버그시 아이디 중복체크 미실시
                print("✅ 디버그모드에서 아이디 중복검사 미실시")
                // ☑️ 상태추적 ☑️
                self?.stateObject.id = id
                self?.output.idValidation?.onNext((true, id))
                return
                #endif
                
                guard let self else { return }
                
                self.inputValidationUseCase
                    .requestCheckingIdDuplication(id: id)
                    .subscribe { [weak self] result in
                        
                        switch result {
                        case .success:
                            printIfDebug("[CenterRegisterViewModel] \(id) 중복체크 결과: ✅ 성공")
                            self?.output.idValidation?.onNext((true, id))
                            
                            // 🚀 상태추적 🚀
                            self?.stateObject.id = id
                            
                        case .failure(let error):
                            printIfDebug("❌ \(id) 아이디중복검사 실패 \n 에러내용: \(error.message)")
                        }
                    }
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                input.editingPassword ?? .empty(),
                input.editingCheckPassword ?? .empty()
            )
            .subscribe(onNext: { [weak self] (pwd, cpwd) in
                
                printIfDebug("[CenterRegisterViewModel] \n 입력중인 비밀번호: \(pwd) \n 확인 비밀번호: \(cpwd)")
                
                guard let self else { return }
                
                let isValid = self.inputValidationUseCase.checkPasswordIsValid(password: pwd)
                
                if !isValid {
                    
                    self.output.passwordValidation?.onNext((.invalidPassword, pwd))
                } else if pwd != cpwd {
                    
                    self.output.passwordValidation?.onNext((.unMatch, pwd))
                } else {
                    
                    self.output.passwordValidation?.onNext((.match, pwd))
                    // 🚀 상태추적 🚀
                    self.stateObject.password = pwd
                }
                
            })
            .disposed(by: disposeBag)
        
        let onComplete = input.ctaButtonClicked?.compactMap({ $0 == .complete ? true : nil })
        
        // MARK: 최종 로그인 버튼
        onComplete?
            .subscribe { [weak self] _ in
                
                guard let self else { return }
                
                self.authUseCase
                    .registerCenterAccount(registerState: self.stateObject)
                    .subscribe { [weak self] result in
                        
                        guard let self else { return }
                        
                        switch result {
                        case .success:
                            self.output.registerValidation?.onNext(true)
                            printIfDebug("[CenterRegisterViewModel] ✅ 회원가입 성공 \n 가임정보 \(self.stateObject.description)")
                            
                            self.stateObject.clear()
                            
                        case .failure(let error):
                            self.output.registerValidation?.onNext(false)
                            printIfDebug("❌ 회원가입 실패: \(error.message)")
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        return output
    }
}

extension CenterRegisterViewModel {
    
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
extension CenterRegisterViewModel {
    
    public class Input {
        
        // CTA 버튼 클릭시
        public var ctaButtonClicked: Observable<CTAButtonAction>?
        
        // 이름입력
        public var editingName: PublishRelay<String?> = .init()
        
        // 전화번호 입력
        public var editingPhoneNumber: PublishRelay<String?> = .init()
        public var editingAuthNumber: PublishRelay<String?> = .init()
        public var requestAuthForPhoneNumber: BehaviorRelay<String?> = .init(value: nil)
        public var requestValidationForAuthNumber: PublishRelay<String?> = .init()
        
        // 사업자 번호 입력
        public var editingBusinessNumber: Observable<String>?
        public var requestBusinessNumberValidation: Observable<String>?
        
        // Id & password
        public var editingId: Observable<String>?
        public var editingPassword: Observable<String>?
        public var editingCheckPassword: Observable<String>?
        public var requestIdDuplicationValidation: Observable<String>?
    }
    
    public struct Output {
        
        // 이름 입력
        public var nameValidation: PublishSubject<(isValid: Bool, name: String)> = .init()
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: PublishRelay<Bool?> = .init()
        public var canSubmitAuthNumber: PublishRelay<Bool?> = .init()
        public var phoneNumberValidation: PublishRelay<Bool?> = .init()
        public var authNumberValidation: PublishRelay<Bool?> = .init()
        
        // 사업자 번호 입력
        public var canSubmitBusinessNumber: PublishSubject<Bool>? = .init()
        public var businessNumberValidation: PublishSubject<BusinessInfoVO?>? = .init()
        
        // Id & password
        public var canCheckIdDuplication: PublishSubject<Bool>? = .init()
        public var idValidation: PublishSubject<(isValid: Bool, id: String)>? = .init()
        public var passwordValidation: PublishSubject<(state: PasswordValidationState, password: String)>? = .init()
        
        // Register success
        public var registerValidation: PublishSubject<Bool>? = .init()
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
extension CenterRegisterViewModel.Input: SetIdPasswordInputable { }
extension CenterRegisterViewModel.Output: SetIdPasswordOutputable { }

// Register
extension CenterRegisterViewModel.Output: RegisterSuccessOutputable { }
