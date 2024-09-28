//
//  AuthInOutStreamManager+IdPassword.swift
//  AuthFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import PresentationCore
import Domain


import RxSwift
import RxCocoa

extension AuthInOutStreamManager {
    
    static func idInOut(
        input: SetIdInputable & AnyObject,
        output: SetIdOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()
    ) {
        
        var output = output
        
        // MARK: Id
        output.canCheckIdDuplication = input
            .editingId
            .map { [unowned useCase] id in
                useCase.checkIdIsValid(id: id)
            }
            .asDriver(onErrorJustReturn: false)
        
        // 중복성 검사
        let idDuplicationValidation = input
            .requestIdDuplicationValidation
            .flatMap { [unowned useCase] id in
                
                printIfDebug("[CenterRegisterViewModel] 중복성 검사 대상 id: \(id)")
                
                #if DEBUG
                // 디버그시 아이디 중복체크 미실시
                print("✅ 디버그모드에서 아이디 중복검사 미실시")
                // ☑️ 상태추적 ☑️
                stateTracker(id)
                return Single.just(Result<String, DomainError>.success(id))
                #endif
                
                return useCase.requestCheckingIdDuplication(id: id)
            }
        
        output.idDuplicationValidation = idDuplicationValidation
            .map { [stateTracker] result in
                switch result {
                case .success(let id):
                    printIfDebug("[CenterRegisterViewModel] 중복체크 결과: ✅ 성공")
                    // 🚀 상태추적 🚀
                    stateTracker(id)
                    return true
                case .failure(let error):
                    printIfDebug("❌ 아이디중복검사 실패 \n 에러내용: \(error.message)")
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
    }
    
    static func passwordInOut(
        input: SetPasswordInputable & AnyObject,
        output: SetPasswordOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()) 
    {
        var output = output
        output.passwordValidation = input.editingPasswords
            .filter { (pwd, cpwd) in !pwd.isEmpty && !cpwd.isEmpty }
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
            .asDriver(onErrorJustReturn: .invalidPassword)
    }
}
