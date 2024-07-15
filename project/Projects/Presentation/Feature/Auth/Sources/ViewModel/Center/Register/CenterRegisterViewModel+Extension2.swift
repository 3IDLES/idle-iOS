//
//  CenterRegisterViewModel+Extension2.swift
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

extension CenterRegisterViewModel {
    
    func validatePhoneNumberInOut() {
        
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
                
                #if DEBUG
                    print("✅ 디버그모드에서 번호인증 요청 무조건 통과")
                    return Single.just(Result<String, InputValidationError>.success(formatted))
                #endif
                
                return self.inputValidationUseCase.requestPhoneNumberAuthentication(phoneNumber: formatted)
            })
            .share()
        
        _ = phoneNumberAuthRequestResult
            .compactMap { $0.value }
            .map { [weak self] phoneNumber in
                printIfDebug("✅ 번호로 인증을 시작합니다.")
                self?.stateObject.phoneNumber = phoneNumber
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
            .compactMap({ [weak self] authNumber in
                if let phoneNumber = self?.stateObject.phoneNumber, let authNumber {
                    return (phoneNumber, authNumber)
                }
                return nil
            })
            .flatMap { [unowned self] (phoneNumber: String, authNumber: String) in
                
                #if DEBUG
                    // 디버그시 인증번호 무조건 통과
                    print("✅ 디버그모드에서 번호인증 무조건 통과")
                    return Single.just(Result<String, InputValidationError>.success(phoneNumber))
                #endif
                
                return self.inputValidationUseCase
                    .authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
            }
            .share()
        
        // 번호인증 성공
        _ = phoneNumberAuthResult
            .compactMap { $0.value }
            .map { phoneNumber in
                
                printIfDebug("✅ \(phoneNumber) 인증성공")
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
}
