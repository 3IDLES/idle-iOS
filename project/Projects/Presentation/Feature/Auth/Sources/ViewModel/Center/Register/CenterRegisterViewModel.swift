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
    
    public init(useCase: CenterRegisterUseCase) {
        self.useCase = useCase
    }
    
    let disposeBag = DisposeBag()
    
    public func transform(input: Input) -> Output {
        
        // MARK: 성함 입력
        input
            .editingName?
            .subscribe(onNext: { name in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 성함: \(name)")
                
                // TODO: 성함이 유효하다면
                self.output.nameValidation?.onNext((!name.isEmpty, name))
                
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
                            guard let idleError = error as? IdleError else { return }
                            printIfDebug("❌ \(formattedString)번호로 인증을 시작할 수 없습니다. \n 에러내용: \(idleError.message)")
                            
                            // TODO: 에러처리 요망
                            
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
                    return
                #endif
                
                self.useCase
                    .authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
                    .subscribe { [weak self] result in
                        switch result {
                        case .success(_):
                            printIfDebug("✅ \(phoneNumber)번호 인증성공")
                            self?.output.authNumberValidation?.onNext((true, authNumber))
                        case .failure(let error):
                            guard let idleError = error as? IdleError else { return }
                            printIfDebug("❌ \(phoneNumber)번호 인증실패 \n 에러내용: \(idleError.message)")
                            
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
                
                // TODO: Id 유효성 검사
                let isValid = !id.isEmpty
                
                self?.output.canCheckIdDuplication?.onNext(isValid)
            })
            .disposed(by: disposeBag)
        
        // 중복성 검사
        input
            .requestIdDuplicationValidation?
            .subscribe(onNext: { [weak self] id in
                
                printIfDebug("[CenterRegisterViewModel] 중복성 검사 대상 id: \(id)")
                
                // TODO: id 중복검사 API 호출
                let isValid = !id.isEmpty
                
                self?.output.idValidation?.onNext((isValid, id))
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                input.editingPassword ?? .empty(),
                input.editingCheckPassword ?? .empty()
            )
            .subscribe(onNext: { [weak self] (pwd, cpwd) in
                
                printIfDebug("[CenterRegisterViewModel] \n 입력중인 비밀번호: \(pwd) \n 확인 비밀번호: \(cpwd)")
                
                // TODO: 패스워드 유효성 로직
                let isValid = pwd.count >= 10
                
                if !isValid {
                    
                    self?.output.passwordValidation?.onNext((.invalidPassword, pwd))
                } else if pwd != cpwd {
                    
                    self?.output.passwordValidation?.onNext((.unMatch, pwd))
                } else {
                    
                    self?.output.passwordValidation?.onNext((.match, pwd))
                }
                
            })
            .disposed(by: disposeBag)
                
        return output
    }
}

// MARK: ViewModel input output
extension CenterRegisterViewModel {
    
    public struct Input {
        
        // CTA 버튼 클릭시
        public var ctaButtonClicked: Observable<UITapGestureRecognizer>?
        
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
