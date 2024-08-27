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
            let authRepository = resolver.resolve(AuthRepository.self)!
            let userProfileRepository = resolver.resolve(UserProfileRepository.self)!
            let userInfoLocalRepository = resolver.resolve(UserInfoLocalRepository.self)!
            
            return DefaultAuthUseCase(
                authRepository: authRepository,
                userProfileRepository: userProfileRepository,
                userInfoLocalRepository: userInfoLocalRepository
            )
        }
        
        container.register(CenterProfileUseCase.self) { resolver in
            let userProfileRepository = resolver.resolve(UserProfileRepository.self)!
            let userInfoLocalRepository = resolver.resolve(UserInfoLocalRepository.self)!
            return DefaultCenterProfileUseCase(
                userProfileRepository: userProfileRepository,
                userInfoLocalRepository: userInfoLocalRepository
            )
        }
        
        container.register(RecruitmentPostUseCase.self) { resolver in
            let repository = resolver.resolve(RecruitmentPostRepository.self)!
            
            return DefaultRecruitmentPostUseCase(
                repository: repository
            )
        }
        
        container.register(WorkerProfileUseCase.self) { resolver in
            let userProfileRepository = resolver.resolve(UserProfileRepository.self)!
            let userInfoLocalRepository = resolver.resolve(UserInfoLocalRepository.self)!
            return DefaultWorkerProfileUseCase(
                userProfileRepository: userProfileRepository,
                userInfoLocalRepository: userInfoLocalRepository
            )
        }
        
        container.register(SettingScreenUseCase.self) { resolver in
            let authRepository = resolver.resolve(AuthRepository.self)!
            let userInfoLocalRepository = resolver.resolve(UserInfoLocalRepository.self)!
            
            return DefaultSettingUseCase(
                authRepository: authRepository,
                userInfoLocalRepository: userInfoLocalRepository
            )
        }
    }
}
