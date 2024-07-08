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
            let useCase = resolver.resolve(CenterRegisterUseCase.self)!
            
            return CenterRegisterViewModel(
                useCase: useCase
            )
        }
    }
}
