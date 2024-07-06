//
//  CenterRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import PresentationCore

public class CenterRegisterViewModel: ViewModelType {
    
    public struct Input {
        public var name: Observable<String>?
        public var ctaButtonClicked: Observable<UITapGestureRecognizer>?
        public var phoneNumber: Observable<String>?
        public var phoneNumberAuthNumber: Observable<String>?
//        var businessNumber: Observable<String>
//        var idString: Observable<String>
//        var passwordString: Observable<String>
//        var passwordCheckString: Observable<String>
    }
    
    public struct Output {
        public let ctaButtonEnabled: BehaviorSubject<Bool>?
        public var startAuth: PublishSubject<String>?
    }
    
    public var input: Input { Input() }
    
    public init() { }
    
    let disposeBag = DisposeBag()
    
    public func transform(input: Input) -> Output {
        
        let output = Output(
            ctaButtonEnabled: .init(value: false),
            startAuth: .init()
        )
        
        // MARK: 성함 입력
        
        input
            .name?
            .subscribe(onNext: { text in
                
                printIfDebug("입력중인 성함: \(text)")
                
                if !text.isEmpty {
                    
                    output.ctaButtonEnabled?.onNext(true)
                }
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 전화번호 입력
        input
            .phoneNumber?
            .subscribe(onNext: { phoneNumber in
                
                printIfDebug("전달받은 전화번호: \(phoneNumber)")
                
                output.startAuth?.onNext(phoneNumber)
            })
            .disposed(by: disposeBag)
        
        input
            .phoneNumberAuthNumber?
            .subscribe(onNext: { authNumber in
                
                printIfDebug("전달받은 인증번호: \(authNumber)")
                
                // 인증번호 확인 로직
                if authNumber.count >= 6 {
                    
                    printIfDebug("✅ 인증번호 매칭 성공: \(authNumber)")
                    
                    output.ctaButtonEnabled?.onNext(true)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: Input Validation

// CTAButton
extension CenterRegisterViewModel.Input: CTAButtonEnableInputable { }
extension CenterRegisterViewModel.Output: CTAButtonEnableOutPutable { }

// Enter name
extension CenterRegisterViewModel.Input: EnterNameInputable { }

// Auth phoneNumber
extension CenterRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension CenterRegisterViewModel.Output: AuthPhoneNumberOutputable { }
