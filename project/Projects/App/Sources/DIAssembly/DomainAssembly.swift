//
//  DomainAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import Domain

import Swinject

public struct DomainAssembly: Assembly {
    
    public init() { }
    
    public func assemble(container: Container) {
        
        // MARK: UseCase
        container.register(NotificationTokenUseCase.self) { _ in
            return DefaultNotificationTokenUseCase()
        }
        .inObjectScope(.container)
        
        container.register(AuthInputValidationUseCase.self) { resolver in
            let repository = resolver.resolve(AuthInputValidationRepository.self)!
            
            return DefaultAuthInputValidationUseCase(repository: repository)
        }
        
        container.register(AuthUseCase.self) { _ in
            return DefaultAuthUseCase()
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
        
        container.register(SettingScreenUseCase.self) { _ in
            return DefaultSettingUseCase()
        }
        
        container.register(CenterCertificateUseCase.self) { resolver in
            let authRepository = resolver.resolve(AuthRepository.self)!
            let userInfoLocalRepository = resolver.resolve(UserInfoLocalRepository.self)!
            
            return DefaultCenterCertificateUseCase(
                authRepository: authRepository,
                userInfoLocalRepository: userInfoLocalRepository
            )
        }
    }
}
