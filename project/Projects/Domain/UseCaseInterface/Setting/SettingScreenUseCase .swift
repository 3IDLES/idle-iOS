//
//  SettingScreenUseCase .swift
//  UseCaseInterface
//
//  Created by choijunios on 8/19/24.
//

import Foundation
import RxSwift
import Entity

public enum NotificationApproveAction: Equatable {
    case openSystemSetting
    case granted
    case error(message: String)
}

public protocol SettingScreenUseCase: UseCaseBase {
    
    /// 현재 알람수신 동의 여부를 확인합니다.
    func checkPushNotificationApproved() -> Single<Bool>
    
    /// 알림동의를 요청합니다.
    func requestNotificationPermission() -> Maybe<NotificationApproveAction>
    
    /// 개인정보 처리방침 웹 URL을 가져옵니다.
    func getPersonalDataUsageDescriptionUrl() -> URL
    
    /// 어플리케이션 이용약관을 가져옵니다.
    func getApplicationPolicyUrl() -> URL
    
    /// 요양보호사 회원 탈퇴
    func deregisterWorkerAccount(
        reasons: [DeregisterReasonVO]
    ) -> Single<Result<Void, DomainError>>
    
    /// 요양보호사 로그아웃
    func signoutWorkerAccount() -> Single<Result<Void, DomainError>>
    
    /// 센터 회원 탈퇴
    func deregisterCenterAccount(
        reasons: [DeregisterReasonVO],
        password: String
    ) -> Single<Result<Void, DomainError>>
    
    /// 센터 로그아웃
    func signoutCenterAccount() -> Single<Result<Void, DomainError>>
}
