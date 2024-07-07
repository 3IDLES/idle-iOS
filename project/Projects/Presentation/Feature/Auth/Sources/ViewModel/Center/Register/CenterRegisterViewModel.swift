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
    
    // Input은 모든 ViewController에서 공유한다. (다만, 각가의 ViewController의 Input프로토콜에 의해 제한된다.)
    public let input = Input()
    public let output = Output()
    
    public init() { }
    
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
                
                // 특정 조건 만족시
                self?.output.canSubmitPhoneNumber?.onNext((10...11).contains(phoneNumber.count))
            })
            .disposed(by: disposeBag)
        
        input
            .editingAuthNumber?
            .subscribe(onNext: { [weak self] authNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 인증번호: \(authNumber)")
                
                self?.output.canSubmitAuthNumber?.onNext(authNumber.count >= 3)
            })
            .disposed(by: disposeBag)
        
        input
            .requestAuthForPhoneNumber?
            .subscribe(onNext: { [weak self] phoneNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전화번호 인증 요청: \(phoneNumber)")
                
                // TODO: 인증요청API 성공시
                
                self?.output.phoneNumberValidation?.onNext((true, phoneNumber))
            })
            .disposed(by: disposeBag)
        
        input
            .requestValidationForAuthNumber?
            .subscribe(onNext: { [weak self] authNumber in
                
                printIfDebug("[CenterRegisterViewModel] 인증번호 검증 요청: \(authNumber)")
                
                // TODO: 인증번호 확인 성공시
                
                self?.output.authNumberValidation?.onNext((true, authNumber))
            })
            .disposed(by: disposeBag)
        
        // MARK: 사업자 번호 입력
        input
            .editingBusinessNumber?
            .subscribe(onNext: { [weak self] businessNumber in
                
                printIfDebug("[CenterRegisterViewModel] 전달받은 사업자 번호: \(businessNumber)")
                
                // 특정 조건 만족시
                self?.output.canSubmitBusinessNumber?.onNext(businessNumber.count == 10)
            })
            .disposed(by: disposeBag)
        
        input
            .requestBusinessNumberValidation?
            .subscribe(onNext: { [weak self] businessNumber in
                
                printIfDebug("[CenterRegisterViewModel] 사업자 번호 인증 요청: \(businessNumber)")
                
                // TODO: 사업자 번호조회 API 성공시
                
                self?.output.businessNumberValidation?.onNext((true, .mock))
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
        public var businessNumberValidation: PublishSubject<(isValid: Bool, info: CenterInformation?)>? = .init()
        
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
