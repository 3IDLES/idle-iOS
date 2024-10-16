//
//  AuthInOutStreamManager+Name.swift
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
    
    static func enterNameInOut(
        input: EnterNameInputable & AnyObject,
        output: EnterNameOutputable & AnyObject,
        useCase: AuthInputValidationUseCase,
        stateTracker: @escaping (String) -> ()
    ) {
        // MARK: 성함입력
        var output = output
        output.nameValidation = input
            .editingName
            .map { [useCase] name in
                printIfDebug("[\(#function)] 입력중인 이름: \(name)")
                let isValid = useCase.checkNameIsValid(name: name)
                if isValid { stateTracker(name) }
                return isValid
            }
            .asDriver(onErrorJustReturn: false)
    }
}
