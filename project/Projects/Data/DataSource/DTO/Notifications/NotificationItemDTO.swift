//
//  NotificationItemDTO.swift
//  DataSource
//
//  Created by choijunios on 10/15/24.
//

import Foundation

public enum NotificationTypeDTO: String, Decodable {
    case APPLICANT
}

public struct NotificationItemDTO: Decodable {
    
    public let id: String
    public let isRead: Bool
    public let title: String
    public let body: String
    // ISO8601
    public let createdAt: String
    public let imageUrlString: String?
    public let notificationType: NotificationTypeDTO
    public let notificationDetails: Decodable
    
    enum CodingKeys: CodingKey {
        case id
        case isRead
        case title
        case body
        case createdAt
        case imageUrl
        case notificationType
        case notificationDetails
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.imageUrlString = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        
        self.notificationType = try container.decode(NotificationTypeDTO.self, forKey: .notificationType)
        
        switch notificationType {
        case .APPLICANT:
            self.notificationDetails = try container.decode(ApplicantInfluxDTO.self, forKey: .notificationDetails)
        }
    }
}

// MARK: DTO for NotificationTypes
public struct ApplicantInfluxDTO: Decodable {
    
    public let jobPostingId: String
}
