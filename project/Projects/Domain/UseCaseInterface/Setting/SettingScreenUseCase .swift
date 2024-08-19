//
//  SettingScreenUseCase .swift
//  UseCaseInterface
//
//  Created by choijunios on 8/19/24.
//

import Foundation
import RxSwift

public enum NotificationApproveAction: Equatable {
    case openSystemSetting
    case granted
    case error(message: String)
}

public protocol SettingScreenUseCase {
    
    /// 현재 알람수신 동의 여부를 확인합니다.
    func checkPushNotificationApproved() -> Single<Bool>
    
    /// 알림동의를 요청합니다.
    func requestNotificationPermission() -> Maybe<NotificationApproveAction>
    
    /// 개인정보 처리방침 웹 URL을 가져옵니다.
    func getPersonalDataUsageDescriptionUrl() -> URL
    
    /// 어플리케이션 이용약관을 가져옵니다.
    func getApplicationPolicyUrl() -> URL
}
