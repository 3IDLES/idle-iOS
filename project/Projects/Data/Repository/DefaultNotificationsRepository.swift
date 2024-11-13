//
//  DefaultNotificationsRepository.swift
//  Repository
//
//  Created by choijunios on 10/15/24.
//

import Foundation
import DataSource
import Domain
import Core


public class DefaultNotificationsRepository: NotificationsRepository {
    
    @Injected var notificationsService: any NotificationsService
    
    public init() { }
    
    public func readNotification(id: String) -> Sult<Void, DomainError> {
        let dataTask = notificationsService
            .request(api: .readNotification(id: id), with: .withToken)
            .mapToVoid()
        return convertToDomain(task: dataTask)
    }
    
    public func unreadNotificationCount() -> Sult<Int, DomainError> {
        let dataTask = notificationsService.request(api: .notReadNotificationsCount, with: .withToken)
            .map { response -> Int in
                let jsonObject = try JSONSerialization.jsonObject(with: response.data) as! [String: Any]
                let count = jsonObject["unreadNotificationCount"] as! Int
                return count
            }
        return convertToDomain(task: dataTask)
    }
    
    public func notifcationList(next: String? = nil) -> Sult<([NotificationVO], String?), DomainError> {
        let dataTask = notificationsService.request(api: .allNotifications(next: next), with: .withToken)
            .map { response in
                let data = response.data
                let decoded = try JSONDecoder().decode(PagableListDTO<NotificationItemDTO>.self, from: data)
                
                let vo = decoded.items.map { dto in
                    dto.toEntity()
                }
                
                return (vo, decoded.next)
            }
        return convertToDomain(task: dataTask)
    }
}

// MARK: mapping DTO to Entity
extension NotificationItemDTO: EntityRepresentable {
    public typealias Entity = NotificationVO
    
    public func toEntity() -> Entity {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var createdDate: Date = .now
        
        if let formatted = dateFormatter.date(from: createdAt) {
            createdDate = formatted
        } else {
            printIfDebug("\(NotificationItemDTO.self): 생성날짜 디코딩 실패")
        }
        
        var notificationDetail: NotificationDestinationForInApp?
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
