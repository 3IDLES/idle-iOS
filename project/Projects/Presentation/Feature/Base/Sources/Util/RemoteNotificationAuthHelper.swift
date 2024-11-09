//
//  RemoteNotificationAuthHelper.swift
//  BaseFeature
//
//  Created by choijunios on 10/9/24.
//

import Foundation
import UserNotifications


import RxSwift


public enum RemoteNotificationApproveAction: Equatable {
    case openSystemSetting
    case granted
    case error(message: String)
}

public class RemoteNotificationAuthHelper {
    
    public static let shared: RemoteNotificationAuthHelper = .init()
    
    private init() { }
    
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
    
    public func requestNotificationPermission() -> Maybe<RemoteNotificationApproveAction> {
        Maybe<RemoteNotificationApproveAction>.create { maybe in
            
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
}

