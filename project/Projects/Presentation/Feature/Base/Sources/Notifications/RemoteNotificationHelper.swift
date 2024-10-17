//
//  RemoteNotificationHelper.swift
//  BaseFeature
//
//  Created by choijunios on 10/17/24.
//

import Foundation
import Domain


import RxSwift

public protocol RemoteNotificationHelper {
    
    var deeplinks: BehaviorSubject<DeeplinkBundle> { get }
    
    /// 인앱에서 발생한 Notification을 처리합니다.
    func handleNotificationInApp(detail: NotificationDetailVO)
}
