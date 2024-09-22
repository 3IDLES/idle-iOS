//
//  DataAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import RepositoryInterface
import ConcreteRepository
import DataSource


import Swinject

public struct DataAssembly: Assembly {
    public func assemble(container: Container) {
        
        // MARK: Service
        container.register(LocalStorageService.self) { _ in
            return DefaultLocalStorageService()
        }
        
        // MARK: 캐싱 레포지토리
        container.register(CacheRepository.self) { _ in
            return DefaultCacheRepository()
        }
        .inObjectScope(.container)
        
        // MARK: 로컬에 저장된 유저정보 레포지토리
        container.register(UserInfoLocalRepository.self) { resolver in
            let localStorageService = resolver.resolve(LocalStorageService.self)!
            return DefaultUserInfoLocalRepository(
                localStorageService: localStorageService
            )
        }
        
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
        
        // MARK: 구인공고 레포지토리
        container.register(RecruitmentPostRepository.self) { _ in
            return DefaultRecruitmentPostRepository()
        }
        
        // MARK: RemoteConfig
        container.register(RemoteConfigRepository.self) { _ in
            return DefaultRemoteConfigRepository()
        }
    }
}
