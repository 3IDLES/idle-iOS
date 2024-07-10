//
//  AuthAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import AuthFeature
import UseCaseInterface
import Swinject

public struct AuthAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(CenterRegisterViewModel.self) { resolver in
            let inputValidationUseCase = resolver.resolve(AuthInputValidationUseCase.self)!
            let authUseCase = resolver.resolve(AuthUseCase.self)!
            
            return CenterRegisterViewModel(
                inputValidationUseCase: inputValidationUseCase,
                authUseCase: authUseCase
            )
        }
        
        container.register(CenterLoginViewModel.self) { resolver in
            
            let authUseCase = resolver.resolve(AuthUseCase.self)!
            
            return CenterLoginViewModel(
                authUseCase: authUseCase
            )
        }
    }
}
