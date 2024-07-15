//
//  CenterRegisterViewModel+Extension4.swift
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
    
    func validateBusinessNumberInOut() {
        // MARK: 사업자 번호 입력
        _ = input
            .editingBusinessNumber
            .compactMap { $0 }
            .map({ [unowned self] businessNumber in
                self.inputValidationUseCase.checkBusinessNumberIsValid(businessNumber: businessNumber)
            })
            .bind(to: output.canSubmitBusinessNumber)
        
        let businessNumberValidationResult = input
            .requestBusinessNumberValidation
            .compactMap { $0 }
            .flatMap({ [unowned self] businessNumber in
                let formatted = self.formatBusinessNumber(businessNumber: businessNumber)
                printIfDebug("[CenterRegisterViewModel] 사업자 번호 인증 요청: \(formatted)")
                return self.inputValidationUseCase
                    .requestBusinessNumberAuthentication(businessNumber: formatted)
            })
            .share()
        
        _ = businessNumberValidationResult
            .compactMap { $0.value }
            .map({ [weak self] (businessNumber, infoVO) in
                printIfDebug("✅ 사업자번호 검색 성공")
                // 🚀 상태추적 🚀
                self?.stateObject.businessNumber = businessNumber
                return infoVO
            })
            .bind(to: output.businessNumberValidation)
        
        
        _ = businessNumberValidationResult
            .compactMap { $0.error }
            .map({ error in
                printIfDebug("❌ 사업자번호 검색실패 \n 에러내용: \(error.message)")
                return nil
            })
            .bind(to: output.businessNumberValidation)
    }

}
