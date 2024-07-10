//
//  DomainAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import UseCaseInterface
import ConcreteUseCase
import RepositoryInterface
import Swinject

public struct DomainAssembly: Assembly {
    public func assemble(container: Container) {
        container.register(AuthInputValidationUseCase.self) { resolver in
            let repository = resolver.resolve(AuthInputValidationRepository.self)!
            
            return DefaultAuthInputValidationUseCase(repository: repository)
        }
        
        container.register(AuthUseCase.self) { resolver in
            let repository = resolver.resolve(AuthRepository.self)!
            
            return DefualtAuthseeCase(repository: repository)
        }
    }
}
