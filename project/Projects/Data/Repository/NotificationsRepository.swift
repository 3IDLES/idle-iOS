//
//  NotificationsRepository.swift
//  Repository
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import DataSource
import Domain
import Core


public class DefaultNotificationsRepository: NotificationsRepository {
    
    let service: NotificationsService = .init()
    
    public init() { }
    
    public func readNotification(id: String) -> Sult<Void, DomainError> {
        let dataTask = service
            .request(api: .readNotification(id: id), with: .withToken)
            .mapToVoid()
        return convertToDomain(task: dataTask)
    }
    
    public func unreadNotificationCount() -> Sult<Int, DomainError> {
        let dataTask = service.request(api: .notReadNotificationsCount, with: .withToken)
            .map { response -> Int in
                let jsonObject = try JSONSerialization.jsonObject(with: response.data) as! [String: Any]
                let count = jsonObject["unreadNotificationCount"] as! Int
                return count
            }
        return convertToDomain(task: dataTask)
    }
    
    public func notifcationList() -> Sult<[NotificationVO], DomainError> {
        let dataTask = service.request(api: .allNotifications, with: .withToken)
            .map { response in
                let data = response.data
                let decoded = try JSONDecoder().decode([NotificationItemDTO].self, from: data)
                return decoded.map { dto in
                    dto.toEntity()
                }
            }
        return convertToDomain(task: dataTask)
    }
}

// MARK: mapping DTO to Entity
extension NotificationItemDTO: EntityRepresentable {
    public typealias Entity = NotificationVO
    
    public func toEntity() -> Entity {
        
        let dateFormatter = ISO8601DateFormatter()
        var createdDate: Date = .now
        
        if let formatted = dateFormatter.date(from: createdAt) {
            createdDate = formatted
        } else {
            printIfDebug("\(NotificationItemDTO.self): 생성날짜 디코딩 실패")
        }
        
        var notificationDetail: NotificationDetailVO?
        switch notificationType {
            case .APPLICANT:
                if let postId = (notificationDetails as? ApplicantInfluxDTO)?.toEntity() {
                    notificationDetail = .applicant(id: postId)
                }
        }
        
        var imageDownloadInfo: ImageDownLoadInfo?
        
        if let imageUrlString {
            
            imageDownloadInfo = .parseURL(string: imageUrlString)
        }
        
        return NotificationVO(
            id: id,
            isRead: isRead,
            title: title,
            body: body,
            createdDate: createdDate,
            imageDownloadInfo: imageDownloadInfo,
            notificationDetails: notificationDetail
        )
    }
}

extension ApplicantInfluxDTO: EntityRepresentable {
    
    public typealias Entity = String
    
    public func toEntity() -> String {
        self.jobPostingId
    }
}
