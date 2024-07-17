//
//  AuthInOutStreamManager+IdPassword.swift
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
    
    static func idInOut(
        input: SetIdInputable & AnyObject,
        output: SetIdOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()
    ) {
        
        // MARK: Id
        _ = input
            .editingId
            .compactMap { $0 }
            .map({ [unowned useCase, output] id in
                output.canCheckIdDuplication.accept(
                    useCase.checkIdIsValid(id: id)
                )
            })
        
        // 중복성 검사
        let idDuplicationValidation = input
            .requestIdDuplicationValidation
            .compactMap { $0 }
            .flatMap { [unowned useCase] id in
                
                printIfDebug("[CenterRegisterViewModel] 중복성 검사 대상 id: \(id)")
                
                #if DEBUG
                // 디버그시 아이디 중복체크 미실시
                print("✅ 디버그모드에서 아이디 중복검사 미실시")
                // ☑️ 상태추적 ☑️
                stateTracker(id)
                return Single.just(Result<String, InputValidationError>.success(id))
                #endif
                
                return useCase.requestCheckingIdDuplication(id: id)
            }
            .share()
        
        _ = idDuplicationValidation
            .compactMap { $0.value }
            .map { [weak output] validId in
                printIfDebug("[CenterRegisterViewModel] \(validId) 중복체크 결과: ✅ 성공")
                // 🚀 상태추적 🚀
                stateTracker(validId)
                output?.idDuplicationValidation.accept(validId)
            }
        
        _ = idDuplicationValidation
            .compactMap { $0.error }
            .map({ [weak output] error in
                printIfDebug("❌ 아이디중복검사 실패 \n 에러내용: \(error.message)")
                output?.idDuplicationValidation.accept(nil)
            })
    }
    
    static func passwordInOut(
        input: SetPasswordInputable & AnyObject,
        output: SetPasswordOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()) {
            
        _ = input.editingPassword
            .compactMap { $0 }
            .map { [unowned useCase] (pwd, cpwd) in
                    
                printIfDebug("[CenterRegisterViewModel] \n 입력중인 비밀번호: \(pwd) \n 확인 비밀번호: \(cpwd)")
                    
                let isValid = useCase.checkPasswordIsValid(password: pwd)
                if !isValid {
                    printIfDebug("❌ 비밀번호가 유효하지 않습니다.")
                    return PasswordValidationState.invalidPassword
                } else if pwd != cpwd {
                    printIfDebug("☑️ 비밀번호가 일치하지 않습니다.")
                    return PasswordValidationState.unMatch
                } else {
                    printIfDebug("✅ 비밀번호가 일치합니다.")
                    stateTracker(pwd)
                    return PasswordValidationState.match
                }
            }
            .map { [weak output] result in
                output?.passwordValidation.accept(result)
            }
    }
}
