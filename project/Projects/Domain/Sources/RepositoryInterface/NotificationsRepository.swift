//
//  NotificationsRepository.swift
//  Domain
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import Core


import RxSwift

public protocol NotificationsRepository: RepositoryBase {
    
    func readNotification(id: String) -> Sult<Void, DomainError>
    
    func notificationCount() -> Sult<Int, DomainError>
    
    func notifcationList() -> Sult<Void, DomainError>
}
