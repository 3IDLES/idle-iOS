//
//  CenterRegisterViewModel+Extension3.swift
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
    
    func registerInOut() {
        // MARK: 최종 회원가입 버튼
        let registerValidation = input
            .ctaButtonClicked
            .compactMap({ $0 })
            .flatMap { [unowned self] _ in
                self.authUseCase
                    .registerCenterAccount(registerState: self.stateObject)
            }
            .share()
        
        _ = registerValidation
            .compactMap { $0.value }
            .map { [unowned self] _ in
                printIfDebug("[CenterRegisterViewModel] ✅ 회원가입 성공 \n 가임정보 \(self.stateObject.description)")
                self.stateObject.clear()
                return true
            }
            .bind(to: output.registerValidation)
        
        _ = registerValidation
            .compactMap { $0.error }
            .map { error in
                printIfDebug("❌ 회원가입 실패: \(error.message)")
                return false
            }
            .bind(to: output.registerValidation)
    }
}
