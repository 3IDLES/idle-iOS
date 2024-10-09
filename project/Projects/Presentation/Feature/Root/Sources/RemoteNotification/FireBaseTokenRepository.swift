//
//  FireBaseTokenRepository.swift
//  RootFeature
//
//  Created by choijunios on 10/8/24.
//

import Foundation
import Domain
import Core


import FirebaseMessaging

public class FCMTokenRepository: NSObject, NotificationTokenRepository {
    
    public weak var delegate: NotificationTokenRepositoryDelegate?
    
    public override init() {
        super.init()
        Messaging.messaging().delegate = self
    }
    
    public func getToken() -> String? {
        Messaging.messaging().fcmToken
    }
}

extension FCMTokenRepository: MessagingDelegate {
    
    // 새로운 토큰 수신
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        if let fcmToken {
            printIfDebug(fcmToken)
            delegate?.notificationToken(freshToken: fcmToken)
        }
    }
}
