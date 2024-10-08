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

public protocol SettingScreenUseCase: BaseUseCase {
    
    /// 현재 알람수신 동의 여부를 확인합니다.
    func checkPushNotificationApproved() -> Single<Bool>
    
    /// 알림동의를 요청합니다.
    func requestNotificationPermission() -> Maybe<NotificationApproveAction>
    
    // MARK: Worker
    
    /// 요양보호사 회원 탈퇴
    func deregisterWorkerAccount(
        reasons: [String]
    ) -> Single<Result<Void, DomainError>>
    
    /// 요양보호사 로그아웃
    func signoutWorkerAccount() -> Single<Result<Void, DomainError>>
    
    // MARK: Center
    
    /// 센터 회원 탈퇴
    func deregisterCenterAccount(
        reasons: [String],
        password: String
    ) -> Single<Result<Void, DomainError>>
    
    /// 센터 로그아웃
    func signoutCenterAccount() -> Single<Result<Void, DomainError>>
}
