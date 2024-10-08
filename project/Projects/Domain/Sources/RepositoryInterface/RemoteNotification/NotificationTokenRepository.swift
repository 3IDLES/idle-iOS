//
//  NotificationTokenRepository.swift
//  Domain
//
//  Created by choijunios on 10/8/24.
//

import Foundation

public protocol NotificationTokenRepository: AnyObject {
    
    // delegate
    var delegate: NotificationTokenRepositoryDelegate? { get set }
    
    func getToken() -> String?
}

public protocol NotificationTokenRepositoryDelegate: AnyObject {
    
    func notificationToken(freshToken: String)
}
