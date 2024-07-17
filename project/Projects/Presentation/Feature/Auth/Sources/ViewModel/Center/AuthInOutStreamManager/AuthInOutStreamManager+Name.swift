//
//  AuthInOutStreamManager+Name.swift
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

enum AuthInOutStreamManager { }

extension AuthInOutStreamManager {
    
    static func enterNameInOut(
        input: EnterNameInputable & AnyObject,
        output: EnterNameOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()
    ) {
        // MARK: 성함입력
        _ = input
            .editingName
            .compactMap({ $0 })
            .map { [weak useCase] name in
                
                guard let useCase else { return (false, name) }
                
                let isValid = useCase.checkNameIsValid(name: name)
                
                if isValid {
                    stateTracker(name)
                }
                
                return (isValid, name)
            }
            .bind(to: output.nameValidation)
    }
}
