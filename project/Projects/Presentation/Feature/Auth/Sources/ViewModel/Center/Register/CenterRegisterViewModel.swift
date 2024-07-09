//
//  CenterRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import PresentationCore
import UseCaseInterface
import Entity

public class CenterRegisterViewModel: ViewModelType {
    
    // UseCase
    public let useCase: CenterRegisterUseCase
    
    // Input은 모든 ViewController에서 공유한다. (다만, 각가의 ViewController의 Input프로토콜에 의해 제한된다.)
    public let input = Input()
    public let output = Output()
    
    private let stateObject = CenterRegisterState()
    
    public init(useCase: CenterRegisterUseCase) {
        self.useCase = useCase
    }
    
    let disposeBag = DisposeBag()
    
    public func transform(input: Input) -> Output {
        
        // MARK: 성함 입력
        input
            .editingName?
            .subscribe(onNext: { [weak self] name in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 성함: \(name)")
                
                // TODO: 성함이 유효하다면
                let isValid = !name.isEmpty
                self?.output.nameValidation?.onNext((isValid, name))
                
                if isValid {
                    // 🚀 상태추적 🚀
                    self?.stateObject.name = name
                }
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 전화번호 입력
        input
            .editingPhoneNumber?
            .subscribe(onNext: { [weak self] phoneNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 전화번호: \(phoneNumber)")
                
                guard let self else { return }
                
                // 특정 조건 만족시
                self.output.canSubmitPhoneNumber?.onNext(
                    self.useCase.checkPhoneNumberIsValid(phoneNumber: phoneNumber)
                )
            })
            .disposed(by: disposeBag)
        
        input
            .editingAuthNumber?
            .subscribe(onNext: { [weak self] authNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 인증번호: \(authNumber)")
                
                self?.output.canSubmitAuthNumber?.onNext(authNumber.count >= 6)
            })
            .disposed(by: disposeBag)
        
        // 인증중인 전화번호를 캐치
        let currentAuthenticatingNumber = PublishSubject<String>()
        
        input
            .requestAuthForPhoneNumber?
            .subscribe(onNext: { [weak self] phoneNumber in
                
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
                
                printIfDebug("[CenterRegisterViewModel] 전화번호 인증 요청: \(formattedString)")
                
                guard let self else { return }
                
                #if DEBUG
                // 디버그시 번호 검사 무조건 통과
                print("✅ 디버그모드에서 번호인증 요청 무조건 통과")
                currentAuthenticatingNumber.onNext(formattedString)
                self.output.phoneNumberValidation?.onNext((true, formattedString))
                return
                #endif
                
                self.useCase
                    .requestPhoneNumberAuthentication(phoneNumber: formattedString)
                    .subscribe { [weak self] result in
                        switch result {
                        case .success(_):
                            printIfDebug("✅ \(formattedString)번호로 인증을 시작합니다.")
                            currentAuthenticatingNumber.onNext(formattedString)
                            
                            self?.output.phoneNumberValidation?.onNext((true, formattedString))
                        case .failure(let error):
                            printIfDebug("❌ \(formattedString)번호로 인증을 시작할 수 없습니다. \n 에러내용: \(error.message)")
                            
                            // TODO: 에러처리
                            
                            self?.output.phoneNumberValidation?.onNext((false, formattedString))
                            return
                        }
                    }
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                currentAuthenticatingNumber,
                input.requestValidationForAuthNumber ?? .empty()
            )
            .subscribe(onNext: { [weak self] (phoneNumber, authNumber) in
                
                printIfDebug("[CenterRegisterViewModel] 인증번호 검증 요청: \n 유저입력 인증번호: \(authNumber) \n 전화번호: \(phoneNumber)")
                
                guard let self else { return }
                
                #if DEBUG
                    // 디버그시 인증번호 무조건 통과
                    print("✅ 디버그모드에서 인증번호 무조건 통과")
                    self.output.authNumberValidation?.onNext((true, authNumber))
                
                    // ☑️ 상태추적 ☑️
                    self.stateObject.phoneNumber = phoneNumber
                    return
                #endif
                
                self.useCase
                    .authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
                    .subscribe { [weak self] result in
                        switch result {
                        case .success(_):
                            printIfDebug("✅ \(phoneNumber)번호 인증성공")
                            self?.output.authNumberValidation?.onNext((true, authNumber))
                            // 🚀 상태추적 🚀
                            self?.stateObject.phoneNumber = phoneNumber
                        case .failure(let error):
                            printIfDebug("❌ \(phoneNumber)번호 인증실패 \n 에러내용: \(error.message)")
                            
                            // TODO: 에러처리
                            
                            self?.output.authNumberValidation?.onNext((false, authNumber))
                            return
                        }
                    }
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // MARK: 사업자 번호 입력
        input
            .editingBusinessNumber?
            .subscribe(onNext: { [weak self] businessNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 사업자 번호: \(businessNumber)")
                
                guard let self else { return }
                
                let isValid = self.useCase.checkBusinessNumberIsValid(businessNumber: businessNumber)
                self.output.canSubmitBusinessNumber?.onNext(isValid)
            })
            .disposed(by: disposeBag)
        
        input
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
                
                self.useCase
                    .requestBusinessNumberAuthentication(businessNumber: formattedString)
                    .subscribe(onNext: { [weak self] result in
                        
                        switch result {
                        case .success(let vo):
                            printIfDebug("✅ \(formattedString)번호 검색 성공")
                            
                            self?.output.businessNumberValidation?.onNext(vo)
                            // 🚀 상태추적 🚀
                            self?.stateObject.businessNumber = businessNumber
                        case .failure(let error):
                            
                            printIfDebug("❌ \(formattedString)번호 검색실패 \n 에러내용: \(error.message)")
                            
                            // TODO: 에러처리
                            
                            self?.output.businessNumberValidation?.onNext(nil)
                        }
                    })
                    .disposed(by: self.disposeBag)
                
            })
            .disposed(by: disposeBag)
        
        // MARK: Id & Password
        input
            .editingId?
            .subscribe(onNext: { [weak self] id in
                
                printIfDebug("[CenterRegisterViewModel] 입력중인 id: \(id)")
                
                guard let self else { return }
                
                let isValid = self.useCase.checkIdIsValid(id: id)
                
                self.output.canCheckIdDuplication?.onNext(isValid)
            })
            .disposed(by: disposeBag)
        
        // 중복성 검사
        input
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
                
                self.useCase
                    .requestCheckingIdDuplication(id: id)
                    .subscribe(onNext: { [weak self] result in
                        
                        switch result {
                        case .success(let isValid):
                            printIfDebug("[CenterRegisterViewModel] \(id) 중복체크 결과: \(isValid ? "✅ 성공" : "❌ 실패")")
                            self?.output.idValidation?.onNext((isValid, id))
                            
                            if isValid {
                                // 🚀 상태추적 🚀
                                self?.stateObject.id = id
                            }
                        case .failure(let error):
                            printIfDebug("❌ \(id) 아이디중복검사 실패 \n 에러내용: \(error.message)")
                        }
                    })
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
                
                let isValid = self.useCase.checkPasswordIsValid(password: pwd)
                
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
                
                self.useCase
                    .registerCenterAccount(registerState: self.stateObject)
                    .subscribe(onNext: { [weak self] result in
                        
                        guard let self else { return }
                        
                        switch result {
                        case .success(_):
                            printIfDebug("[CenterRegisterViewModel] ✅ 획원가입 성공 \n 가임정보 \(self.stateObject)")
                        case .failure(let error):
                            printIfDebug("❌ 회원가입 실패: \(error.message)")
                        }
                        
                        // 현재까지 입력정보를 모두 삭제
                        self.stateObject.clear()
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        return output
    }
}

// MARK: ViewModel input output
extension CenterRegisterViewModel {
    
    public struct Input {
        
        // CTA 버튼 클릭시
        public var ctaButtonClicked: Observable<CTAButtonAction>?
        
        // 이름입력
        public var editingName: Observable<String>?
        
        // 전화번호 입력
        public var editingPhoneNumber: Observable<String>?
        public var editingAuthNumber: Observable<String>?
        public var requestAuthForPhoneNumber: Observable<String>?
        public var requestValidationForAuthNumber: Observable<String>?
        
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
        public var nameValidation: PublishSubject<(isValid: Bool, name: String)>? = .init()
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: PublishSubject<Bool>? = .init()
        public var canSubmitAuthNumber: PublishSubject<Bool>? = .init()
        public var phoneNumberValidation: PublishSubject<(isValid: Bool, phoneNumber: String)>? = .init()
        public var authNumberValidation: PublishSubject<(isValid: Bool, authNumber: String)>? = .init()
        
        // 사업자 번호 입력
        public var canSubmitBusinessNumber: PublishSubject<Bool>? = .init()
        public var businessNumberValidation: PublishSubject<BusinessInfoVO?>? = .init()
        
        // Id & password
        public var canCheckIdDuplication: PublishSubject<Bool>? = .init()
        public var idValidation: PublishSubject<(isValid: Bool, id: String)>? = .init()
        public var passwordValidation: PublishSubject<(state: PasswordValidationState, password: String)>? = .init()
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
