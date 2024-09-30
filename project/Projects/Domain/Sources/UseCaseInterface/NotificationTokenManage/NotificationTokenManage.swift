//
//  NotificationTokenManage.swift
//  UseCaseInterface
//
//  Created by choijunios on 9/26/24.
//

import Foundation

public protocol NotificationTokenManage {
    
    /// 유저와 매치되는 노티피케이션 토큰을 서버로 전송합니다.
    func setNotificationToken(token: String, completion: @escaping (Bool) -> ())
    
    /// 유저와 매치되는 노티피케이션 토큰을 서버로부터 제거합니다.
    func deleteNotificationToken(completion: @escaping (Bool) -> ())
}
