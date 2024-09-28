//
//  NotificationPageUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 9/28/24.
//

import Foundation
import Entity


import RxSwift

public protocol NotificationPageUseCase: BaseUseCase {
    
    /// 알림 내역 획득
    func getNotificationList() -> Single<Result<[NotificationCellInfo], DomainError>>
}
