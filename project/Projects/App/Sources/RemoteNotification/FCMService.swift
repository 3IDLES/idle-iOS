//
//  FCMService.swift
//  Idle-iOS
//
//  Created by choijunios on 9/24/24.
//

import Foundation
import FirebaseMessaging

class DefaultFCMService: NSObject {
    
    override public init() {
        super.init()
        Messaging.messaging().delegate = self
    }
}

extension DefaultFCMService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM토큰(new): \(String(describing: fcmToken))")
        
        let userId = ""
        
        if let fcmToken {
            
        }
    }
}


extension DefaultFCMService: UNUserNotificationCenterDelegate {
    
    /// 앱이 포그라운드에 있는 경우, 노티페이케이션이 도착하기만 하면 호출된다.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    /// 앱이 백그라운드에 있는 경우, 유저가 노티피케이션을 통해 액션을 선택한 경우 호출
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo)
    }
}
