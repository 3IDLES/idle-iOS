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
            DefaultNotificationTokenUseCase()
        }
        .inObjectScope(.container)
        
        container.register(AuthInputValidationUseCase.self) { _ in
            DefaultAuthInputValidationUseCase()
        }
        
        container.register(AuthUseCase.self) { _ in
            DefaultAuthUseCase()
        }
        
        container.register(CenterProfileUseCase.self) { _ in
            DefaultCenterProfileUseCase()
        }
        
        container.register(RecruitmentPostUseCase.self) { _ in
            DefaultRecruitmentPostUseCase()
        }
        
        container.register(WorkerProfileUseCase.self) { _ in
            DefaultWorkerProfileUseCase()
        }
        
        container.register(SettingScreenUseCase.self) { _ in
            DefaultSettingUseCase()
        }
        
        container.register(CenterCertificateUseCase.self) { _ in
            DefaultCenterCertificateUseCase()
        }
    }
}
