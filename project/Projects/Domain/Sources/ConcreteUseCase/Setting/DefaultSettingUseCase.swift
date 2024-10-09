//
//  DefaultSettingUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/19/24.
//

import Foundation
import UserNotifications
import Core


import RxSwift

public class DefaultSettingUseCase: SettingScreenUseCase {
    
    // UseCase
    @Injected var notificationTokenUseCase: NotificationTokenUseCase
    
    // Repository
    @Injected var authRepository: AuthRepository
    @Injected var userInfoLocalRepository: UserInfoLocalRepository
    
    public init() { }
    
    public func checkPushNotificationApproved() -> Single<Bool> {
        Single<Bool>.create { single in
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined, .denied:
                    single(.success(false))
                case .authorized, .provisional, .ephemeral:
                    single(.success(true))
                @unknown default:
                    single(.success(false))
                }
            }
            
            return Disposables.create { }
        }
    }
    
    public func requestNotificationPermission() -> Maybe<NotificationApproveAction> {
        Maybe<NotificationApproveAction>.create { maybe in
            
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings { [maybe] settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Request permission since the user hasn't decided yet.
                    current.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if error != nil {
                            maybe(.success(.error(message: "알람동의를 수행할 수 없습니다.")))
                        } else {
                            maybe(.success(.granted))
                        }
                    }
                case .denied:
                    // 사용자가 요청을 거부했던 상태로 설정앱을 엽니다.
                    maybe(.success(.openSystemSetting))
                    return
                case .authorized, .provisional, .ephemeral:
                    maybe(.success(.granted))
                default:
                    maybe(.completed)
                    break
                }
            }
            
            return Disposables.create { }
        }
    }
    
    // MARK: 회원탈퇴 & 로그아웃
    // 센터 회원탈퇴
    public func deregisterCenterAccount(reasons: [String], password: String) -> RxSwift.Single<Result<Void, DomainError>> {
        
        notificationTokenUseCase
            .deleteNotificationToken()
            .flatMap{ [authRepository] result in
                
                switch result {
                case .success:
                    authRepository
                        .deregisterCenterAccount(reasons: reasons, password: password)
                        .map { [weak self] result in
                            if case .success = result {
                                self?.removeAllLocalData()
                            }
                            return result
                        }
                case .failure:
                    Single.just(result)
                }
            }
    }
    
    // 센터 로그아웃
    public func signoutCenterAccount() -> RxSwift.Single<Result<Void, DomainError>> {
        notificationTokenUseCase
            .deleteNotificationToken()
            .flatMap{ [authRepository] result in
                
                switch result {
                case .success:
                    authRepository
                        .signoutCenterAccount()
                        .map { [weak self] result in
                            if case .success = result {
                                self?.removeAllLocalData()
                            }
                            return result
                        }
                case .failure:
                    Single.just(result)
                }
            }
    }
    
    // 요양보호사 회원탈퇴
    public func deregisterWorkerAccount(reasons: [String]) -> RxSwift.Single<Result<Void, DomainError>> {
        authRepository
            .deregisterWorkerAccount(reasons: reasons)
            .map { [weak self] result in
                if case .success = result {
                    self?.removeAllLocalData()
                }
                return result
            }
    }
    
    // 요양보호사 로그아웃
    public func signoutWorkerAccount() -> RxSwift.Single<Result<Void, DomainError>> {
        authRepository
            .signoutWorkerAccount()
            .map { [weak self] result in
                if case .success = result {
                    self?.removeAllLocalData()
                }
                return result
            }
    }
    
    private func removeAllLocalData() {
        userInfoLocalRepository.removeAllData()
    }
}
