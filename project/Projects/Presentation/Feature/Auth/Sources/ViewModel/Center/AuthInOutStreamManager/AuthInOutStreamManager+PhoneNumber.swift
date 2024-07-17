//
//  AuthInOutStreamManager+PhoneNumber.swift
//  AuthFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore
import UseCaseInterface
import Entity

extension AuthInOutStreamManager {
    
    static func validatePhoneNumberInOut(
        input: AuthPhoneNumberInputable & AnyObject,
        output: AuthPhoneNumberOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()
    ) {
        // MARK: 전화번호 입력
        _ = input
            .editingPhoneNumber
            .compactMap({ $0 })
            .map({ [unowned useCase] phoneNumber in
                printIfDebug("[CenterRegisterViewModel] 전달받은 전화번호: \(phoneNumber)")
                return useCase.checkPhoneNumberIsValid(phoneNumber: phoneNumber)
            })
            .map({ [weak output] isValid in
                output?.canSubmitPhoneNumber.accept(isValid)
            })
        
        _ = input
            .editingAuthNumber
            .compactMap({ $0 })
            .map({ [weak output] authNumber in
                printIfDebug("[CenterRegisterViewModel] 전달받은 인증번호: \(authNumber)")
                output?.canSubmitAuthNumber.accept(authNumber.count == 6)
            })
        
        let phoneNumberAuthRequestResult = input
            .requestAuthForPhoneNumber
            .compactMap({ $0 })
            .flatMap({ [unowned useCase] number in
                
                let formatted = Self.formatPhoneNumber(phoneNumber: number)
#if DEBUG
                print("✅ 디버그모드에서 번호인증 요청 무조건 통과")
                return Single.just(Result<String, InputValidationError>.success(formatted))
#endif
                
                return useCase.requestPhoneNumberAuthentication(phoneNumber: formatted)
            })
            .share()
        
        var authingNumber: String = ""
        
        _ = phoneNumberAuthRequestResult
            .compactMap { $0.value }
            .map { [weak output] phoneNumber in
                printIfDebug("✅ 번호로 인증을 시작합니다.")
                authingNumber = phoneNumber
                output?.phoneNumberValidation.accept(true)
            }
        
        _ = phoneNumberAuthRequestResult
            .compactMap { $0.error }
            .map { [weak output] error in
                printIfDebug("❌ 인증을 시작할 수 없습니다. \n 에러내용: \(error.message)")
                output?.phoneNumberValidation.accept(false)
            }
        
        
        let phoneNumberAuthResult = input.requestValidationForAuthNumber
            .compactMap({ authNumber in
                if let authNumber {
                    return (authingNumber, authNumber)
                }
                return nil
            })
            .flatMap { [unowned useCase] (phoneNumber: String, authNumber: String) in
                
#if DEBUG
                // 디버그시 인증번호 무조건 통과
                print("✅ 디버그모드에서 번호인증 무조건 통과")
                return Single.just(Result<String, InputValidationError>.success(phoneNumber))
#endif
                
                return useCase.authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
            }
            .share()
        
        // 번호인증 성공
        _ = phoneNumberAuthResult
            .compactMap { $0.value }
            .map { [weak output] phoneNumber in
                printIfDebug("✅ \(phoneNumber) 인증성공")
                stateTracker(phoneNumber)
                output?.authNumberValidation.accept(true)
            }
    
        // 번호인증 실패
        _ = phoneNumberAuthResult
            .compactMap { $0.error }
            .map { [weak output] error in
                printIfDebug("❌ 번호 인증실패 \n 에러내용: \(error.message)")
                output?.authNumberValidation.accept(false)
            }
    }
}

extension AuthInOutStreamManager {
    
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
