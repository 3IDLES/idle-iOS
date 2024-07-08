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
        container.register(CenterRegisterUseCase.self) { resolver in
            let repository = resolver.resolve(CenterRegisterRepository.self)!
            
            return DefaultCenterRegisterUseCase(repository: repository)
        }
    }
}
