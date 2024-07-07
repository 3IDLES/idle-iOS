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
        
//        var businessNumber: Observable<String>
//        var idString: Observable<String>
//        var passwordString: Observable<String>
//        var passwordCheckString: Observable<String>
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
