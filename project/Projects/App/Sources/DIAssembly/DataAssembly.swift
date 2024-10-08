//
//  DataAssembly.swift
//  Idle-iOS
//
//  Created by choijunios on 7/8/24.
//

import Foundation
import Domain
import Repository
import DataSource
import RootFeature


import Swinject

public struct DataAssembly: Assembly {
    
    public init() { }
    
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
        
        // MARK: 토큰 전송 레포지토리
        container.register(NotificationTokenTransferRepository.self) { _ in
            return DefaultNotificationTokenTransferRepository()
        }
        
        // MARK: 토큰 획득 레포지토리
        container.register(NotificationTokenRepository.self) { _ in
            return RootFeature.FCMTokenRepository()
        }
    }
}
