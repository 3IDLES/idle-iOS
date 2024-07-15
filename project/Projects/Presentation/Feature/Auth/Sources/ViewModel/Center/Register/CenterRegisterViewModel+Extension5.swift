//
//  CenterRegisterViewModel+Extension5.swift
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
    
    func IdPasswordInOut() {
        
        // MARK: Id & Password
        _ = input
            .editingId
            .compactMap { $0 }
            .map({ [unowned self] id in
                self.inputValidationUseCase.checkIdIsValid(id: id)
            })
            .bind(to: output.canCheckIdDuplication)
        
        // 중복성 검사
        let idDuplicationValidation = input
            .requestIdDuplicationValidation
            .compactMap { $0 }
            .flatMap { [unowned self] id in
                
                printIfDebug("[CenterRegisterViewModel] 중복성 검사 대상 id: \(id)")
                
                #if DEBUG
                // 디버그시 아이디 중복체크 미실시
                print("✅ 디버그모드에서 아이디 중복검사 미실시")
                // ☑️ 상태추적 ☑️
                self.stateObject.id = id
                return Single.just(Result<String, InputValidationError>.success(id))
                #endif
                
                return self.inputValidationUseCase.requestCheckingIdDuplication(id: id)
            }
            .share()
        
        _ = idDuplicationValidation
            .compactMap { $0.value }
            .map { [weak self] validId in
                printIfDebug("[CenterRegisterViewModel] \(validId) 중복체크 결과: ✅ 성공")
                // 🚀 상태추적 🚀
                self?.stateObject.id = validId
                return validId
            }
            .bind(to: output.idDuplicationValidation)
        
        _ = idDuplicationValidation
            .compactMap { $0.error }
            .map({ error in
                printIfDebug("❌ 아이디중복검사 실패 \n 에러내용: \(error.message)")
                return nil
            })
            .bind(to: output.idDuplicationValidation)
        
        
        _ = input.editingPassword
            .compactMap { $0 }
            .map { [unowned self] (pwd, cpwd) in
                
                printIfDebug("[CenterRegisterViewModel] \n 입력중인 비밀번호: \(pwd) \n 확인 비밀번호: \(cpwd)")
                
                let isValid = self.inputValidationUseCase.checkPasswordIsValid(password: pwd)
                
                if !isValid {
                    return PasswordValidationState.invalidPassword
                } else if pwd != cpwd {
                    return PasswordValidationState.unMatch
                } else {
                    // 🚀 상태추적 🚀
                    self.stateObject.password = pwd
                    return PasswordValidationState.match
                }
            }
            .bind(to: output.passwordValidation)
    }
}
