//
//  FCMService.swift
//  Idle-iOS
//
//  Created by choijunios on 9/24/24.
//

import Foundation
import BaseFeature
import UseCaseInterface
import PresentationCore


import FirebaseMessaging

class FCMService: NSObject {
    
    @Injected var notificationTokenManageUseCase: NotificationTokenManage
    
    override public init() {
        super.init()
        Messaging.messaging().delegate = self
        
        
        // Notification설정
        subscribeNotification()
    }
    
    func subscribeNotification() {
        
        NotificationCenter.default.addObserver(
            forName: .requestTransportTokenToServer,
            object: nil,
            queue: nil) { [weak self] _ in
                
                guard let self else { return }
                
                if let token = Messaging.messaging().fcmToken {
                    
                    notificationTokenManageUseCase.setNotificationToken(
                        token: token) { result in
                            
                            print("FCMService 토큰 전송 \(result ? "완료" : "실패")")
                        }
                }
            }
        
        NotificationCenter.default.addObserver(
            forName: .requestDeleteTokenFromServer,
            object: nil,
            queue: nil) { [weak self] _ in
                
                guard let self else { return }
                
                notificationTokenManageUseCase.deleteNotificationToken(completion: { result in
                    print("FCMService 토큰 삭제 \(result ? "완료" : "실패")")
                })
            }
    }
}

extension FCMService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        if let fcmToken {
            
            print("FCM토큰: \(fcmToken)")
            
            notificationTokenManageUseCase.setNotificationToken(token: fcmToken) { isSuccess in
                
                print(isSuccess ? "토큰 전송 성공" : "토큰 전송 실패")
            }
        }
    }
}


extension FCMService: UNUserNotificationCenterDelegate {
    
    /// 앱이 포그라운드에 있는 경우, 노티페이케이션이 도착하기만 하면 호출된다.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    /// 앱이 백그라운드에 있는 경우, 유저가 노티피케이션을 통해 액션을 선택한 경우 호출
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo)
    }
}
