//
//  MockNotificationsRepository.swift
//  Testing
//
//  Created by choijunios on 10/21/24.
//

import Foundation

import Domain
import Core

class MockNotificationsRepository: NotificationsRepository {
    
    func notifcationList(next: String?) -> Core.Sult<([Domain.NotificationVO], String?), Domain.DomainError> {
        .just(.success(([], nil)))
    }
    
    func readNotification(id: String) -> Sult<Void, Domain.DomainError> {
        .just(.success(()))
    }
    
    func unreadNotificationCount() -> Sult<Int, Domain.DomainError> {
        .just(.success(1))
    }
    
    func notifcationList(next: String? = nil) -> Sult<[Domain.NotificationVO], Domain.DomainError> {
        .just(.success([]))
    }
}
