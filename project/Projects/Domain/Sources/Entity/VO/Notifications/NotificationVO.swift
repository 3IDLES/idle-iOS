//
//  NotificationVO.swift
//  Domain
//
//  Created by choijunios on 10/15/24.
//

import Foundation

public struct NotificationVO {
    
    public let id: String
    public let isRead: Bool
    public let title: String
    public let body: String
    public let createdDate: Date
    public let imageUrl: URL?
    public let notificationDetails: NotificationDetailVO?
    
    public init(
        id: String,
        isRead: Bool,
        title: String,
        body: String,
        createdDate: Date,
        imageUrl: URL?,
        notificationDetails: NotificationDetailVO?
    ) {
        self.id = id
        self.isRead = isRead
        self.title = title
        self.body = body
        self.createdDate = createdDate
        self.imageUrl = imageUrl
        self.notificationDetails = notificationDetails
    }
}

public enum NotificationDetailVO {
    case applicant(id: String)
}
