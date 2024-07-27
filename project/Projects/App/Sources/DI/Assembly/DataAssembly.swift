//
//  DataAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RepositoryInterface
import ConcreteRepository
import Swinject

public struct DataAssembly: Assembly {
    public func assemble(container: Container) {
        
        // MARK: 회원가입 입력 검증 레포지토리
        container.register(AuthInputValidationRepository.self) { _ in
            return DefaultAuthInputValidationRepository()
        }
        
        // MARK: 로그인/회원가입 레포지토리
        container.register(AuthRepository.self) { _ in
            return DefaultAuthRepository()
        }
        
        // MARK: 유저프로필 레포지토리
        container.register(UserProfileRepository.self) { _ in
            return DefaultUserProfileRepository()
        }
    }
}
