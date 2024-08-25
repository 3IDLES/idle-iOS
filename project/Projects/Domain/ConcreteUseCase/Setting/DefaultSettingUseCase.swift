//
//  DefaultSettingUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/19/24.
//

import Foundation
import RxSwift
import UserNotifications
import UseCaseInterface
import RepositoryInterface
import Entity

public class DefaultSettingUseCase: SettingScreenUseCase {
    
    let repository: AuthRepository
    
    public init(repository: AuthRepository) {
        self.repository = repository
    }
    
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
    
    public func getPersonalDataUsageDescriptionUrl() -> URL {
        URL(string: "")!
    }
    
    public func getApplicationPolicyUrl() -> URL {
        URL(string: "")!
    }
    
    // 센터 회원탈퇴
    public func deregisterCenterAccount(reasons: [Entity.DeregisterReasonVO], password: String) -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        convert(
            task: repository.deregisterCenterAccount(reasons: reasons, password: password)
        )
    }
    
    // 센터 로그아웃
    public func signoutCenterAccount() -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        convert(
            task: repository.signoutCenterAccount()
        )
    }
    
    // 요양보호사 회원탈퇴
    public func deregisterWorkerAccount(reasons: [Entity.DeregisterReasonVO]) -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        convert(task: repository.deregisterWorkerAccount(reasons: reasons))
    }
    
    // 요양보호사 로그아웃
    public func signoutWorkerAccount() -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        convert(task: repository.signoutWorkerAccount())
    }
}
