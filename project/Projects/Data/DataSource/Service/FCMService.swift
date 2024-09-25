//
//  FCMService.swift
//  DataSource
//
//  Created by choijunios on 9/25/24.
//

import Foundation

public protocol FCMService {
    
    /// 현재 기기의 FCM 토큰을 획득합니다.
    func sendTokenToServer(identifier: String, fcmToken: String)
}

public extension FCMService {
    
    func sendTokenToServer(identifier: String, fcmToken: String) {
        
        // 토큰 서버전송
    }
}
