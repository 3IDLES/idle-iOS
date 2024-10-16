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
        
        // MARK: Key-value store for datasource
        container.register(KeyValueStore.self) { _ in
            return KeyChainList()
        }
        .inObjectScope(.container)
        
        // MARK: Service
        container.register(LocalStorageService.self) { _ in
            return DefaultLocalStorageService()
        }
        container.register((any ApplyService).self) { _ in
            DefaultApplyService()
        }
        container.register((any AuthService).self) { _ in
            DefaultAuthService()
        }
        container.register((any CrawlingPostService).self) { _ in
            DefaultCrawlingPostService()
        }
        container.register((any ExternalRequestService).self) { _ in
            DefaultExternalRequestService()
        }
        container.register((any NotificationsService).self) { _ in
            DefaultNotificationsService()
        }
        container.register((any NotificationTokenTransferService).self) { _ in
            DefaultNotificationTokenTransferService()
        }
        container.register((any RecruitmentPostService).self) { _ in
            DefaultRecruitmentPostService()
        }
        container.register((any UserInformationService).self) { _ in
            DefaultUserInformationService()
        }
        
        
        // MARK: 캐싱 레포지토리
        container.register(CacheRepository.self) { _ in
            return DefaultCacheRepository()
        }
        .inObjectScope(.container)
        
        // MARK: 로컬에 저장된 유저정보 레포지토리
        container.register(UserInfoLocalRepository.self) { _ in
            DefaultUserInfoLocalRepository()
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
        
        // MARK: 알림 데이터 레포지토리
        container.register(NotificationsRepository.self) { _ in
            DefaultNotificationsRepository()
        }
    }
}
