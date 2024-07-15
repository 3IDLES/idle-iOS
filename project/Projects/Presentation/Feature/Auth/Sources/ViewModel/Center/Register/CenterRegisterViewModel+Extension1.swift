//
//  CenterRegisterViewModel+Extension1.swift
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
    
    func enterNameInOut() {
        // MARK: 성함입력
        _ = input
            .editingName
            .compactMap({ $0 })
            .map { [weak self] name in
                
                guard let self else { return (false, name) }
                
                let isValid = self.inputValidationUseCase.checkNameIsValid(name: name)
                
                if isValid {
                    // 🚀 상태추적 🚀
                    self.stateObject.name = name
                }
                
                return (isValid, name)
            }
            .bind(to: output.nameValidation)
    }
}
