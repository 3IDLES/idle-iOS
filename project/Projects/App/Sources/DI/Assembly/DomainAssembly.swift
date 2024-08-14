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
            
            return DefaultAuthUseCase(repository: repository)
        }
        
        container.register(CenterProfileUseCase.self) { resolver in
            let repository = resolver.resolve(UserProfileRepository.self)!
            
            return DefaultCenterProfileUseCase(repository: repository)
        }
        
        container.register(RecruitmentPostUseCase.self) { resolver in
            let repository = resolver.resolve(RecruitmentPostRepository.self)!
            
            return DefaultRecruitmentPostUseCase(
                repository: repository
            )
        }
        
        container.register(WorkerProfileUseCase.self) { resolver in
            let repository = resolver.resolve(UserProfileRepository.self)!
            
            return DefaultWorkerProfileUseCase(repository: repository)
        }
        
    }
}
