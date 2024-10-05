//
//  AuthInOutStreamManager+PhoneNumber.swift
//  BaseFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import PresentationCore
import Domain
import Core


import RxSwift
import RxCocoa

public extension AuthInOutStreamManager {
    
    static func validatePhoneNumberInOut(
        input: AuthPhoneNumberInputable & AnyObject,
        output: AuthPhoneNumberOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        authUseCase: AuthUseCase? = nil,
        disposeBag: DisposeBag,
        stateTracker: @escaping (String) -> ()
    ) {
        
        var output = output
        
        // MARK: 전화번호 입력
        output.canSubmitPhoneNumber = input
            .editingPhoneNumber
            .map({ [unowned useCase] phoneNumber in
                printIfDebug("전달받은 전화번호: \(phoneNumber)")
                return useCase.checkPhoneNumberIsValid(phoneNumber: phoneNumber)
            })
            .asDriver(onErrorJustReturn: false)
        
        output.canSubmitAuthNumber = input
            .editingAuthNumber
            .compactMap({ $0 })
            .map { authNumber in
                printIfDebug("전달받은 인증번호: \(authNumber)")
                
                return authNumber.count == 6
            }
            .asDriver(onErrorJustReturn: false)
        
        let phoneNumberAuthRequestResult = input
            .requestAuthForPhoneNumber
            .flatMap { [useCase, input] _ in

                let formatted = Self.formatPhoneNumber(phoneNumber: input.editingPhoneNumber.value)
#if DEBUG
                print("✅ 디버그모드에서 번호인증 요청 무조건 통과")
                return Single.just(Result<String, DomainError>.success(formatted))
#endif
                return useCase.requestPhoneNumberAuthentication(phoneNumber: formatted)
            }
            .share()
        
        output
            .phoneNumberValidation = phoneNumberAuthRequestResult
            .compactMap { $0.value }
            .map { phoneNumber in
                printIfDebug("✅ \(phoneNumber) 번호로 인증을 시작합니다.")
                return true
            }
            .asDriver(onErrorJustReturn: false)

        let phoneNumeberAuthRequestFailure = phoneNumberAuthRequestResult
            .compactMap { $0.error }
            .map { error in
                printIfDebug("❌ 인증을 시작할 수 없습니다. \n 에러내용: \(error.message)")
                return error.message
            }
        
        // AuthUseCase를 전달받은 경우 = "요양보호사 로그인을 포함한다"
        var phoneNumeberAuthFailure: Observable<String>!
        
        if let authUseCase {
            
            let loginResult = input.requestValidationForAuthNumber
                .flatMap { [authUseCase, unowned input] _ in
                    
                    let phoneNumber = formatPhoneNumber(phoneNumber: input.editingPhoneNumber.value)
                    let authNumber = input.editingAuthNumber.value
                    
                    return authUseCase.loginWorkerAccount(
                        phoneNumber: phoneNumber,
                        authNumber: authNumber
                    )
                }
                .share()
            
            // 로그인 성공
            output.loginSuccess = loginResult
                .compactMap { $0.value }
                .map { phoneNumber in
                    
                    // 원격 알림 토큰 전송
                    NotificationCenter.default.post(name: .requestTransportTokenToServer, object: nil)
                    
                    printIfDebug("✅ 요양보호사 로그인 성공")
                    return ()
                }
                .asDriver(onErrorJustReturn: ())
            
            // 로그인 실패시 번호인증 진행(신규가입자라고 판단)
            let phoneNumberAuthResult = loginResult
                .compactMap { $0.error }
                .flatMap { [useCase, unowned input] error in
                    printIfDebug("❌ 로그인 실패: \(error.message)")
                    
                    // 번호인증 시도
                    let phoneNumber = formatPhoneNumber(phoneNumber: input.editingPhoneNumber.value)
                    let authNumber = input.editingAuthNumber.value
                    
    #if DEBUG
                    // 디버그시 인증번호 무조건 통과
                    print("✅ 디버그모드에서 번호인증 무조건 통과")
                    return Single.just(Result<String, DomainError>.success(phoneNumber))
    #endif
                    
                    return useCase.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
                }
                .share()
            
            // 번호인증 성공
            output.authNumberValidation = phoneNumberAuthResult
                .compactMap { $0.value }
                .map { phoneNumber in
                    printIfDebug("✅ \(phoneNumber) 인증성공")
                    stateTracker(phoneNumber)
                    return true
                }
                .asDriver(onErrorJustReturn: false)
            
            // 번호인증 실패
            phoneNumeberAuthFailure = phoneNumberAuthResult
                .compactMap { $0.error?.message }
                .asObservable()
        } else {
            
            let phoneNumberAuthResult = input.requestValidationForAuthNumber
                .flatMap { [useCase, unowned input] _ in
                    
                    let phoneNumber = formatPhoneNumber(phoneNumber: input.editingPhoneNumber.value)
                    let authNumber = input.editingAuthNumber.value
    #if DEBUG
                    // 디버그시 인증번호 무조건 통과
                    print("✅ 디버그모드에서 번호인증 무조건 통과")
                    return Single.just(Result<String, DomainError>.success(phoneNumber))
    #endif
                    
                    return useCase.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
                }
                .share()
            
            // 번호인증 성공
            output.authNumberValidation = phoneNumberAuthResult
                .compactMap { $0.value }
                .map { phoneNumber in
                    printIfDebug("✅ \(phoneNumber) 인증성공")
                    stateTracker(phoneNumber)
                    return true
                }
                .asDriver(onErrorJustReturn: false)
            
            // 번호인증 실패
            phoneNumeberAuthFailure = phoneNumberAuthResult
                .compactMap { $0.error?.message ?? nil }
                .asObservable()
        }
        
        // 번호 인증 관련 Alert
        let failureAlert = Observable
            .merge(
                phoneNumeberAuthRequestFailure,
                phoneNumeberAuthFailure
            )
            .map { errorMessage in
                DefaultAlertContentVO(
                    title: "번호 인증 실패",
                    message: errorMessage
                )
            }
        
        failureAlert
            .subscribe(onNext: { [input] alertVO in
                input.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
    }
}

public extension AuthInOutStreamManager {
    
    static func formatPhoneNumber(phoneNumber: String) -> String {
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
    
    static func formatBusinessNumber(businessNumber: String) -> String {
        
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
        
        return formattedString
    }
}
