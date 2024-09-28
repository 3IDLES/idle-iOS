//
//  NotificationInfo.swift
//  Entity
//
//  Created by choijunios on 9/28/24.
//

import Foundation

public struct NotificationCellInfo {
    
    public let id: String
    public let isRead: Bool
    public let notificationDate: Date
    
    // Contents
    public let titleText: String
    public let subTitleText: String
    public let imageInfo: ImageDownLoadInfo
    
    public init(id: String, isRead: Bool, notificationDate: Date, titleText: String, subTitleText: String, imageInfo: ImageDownLoadInfo) {
        self.id = id
        self.isRead = isRead
        self.notificationDate = notificationDate
        self.titleText = titleText
        self.subTitleText = subTitleText
        self.imageInfo = imageInfo
    }
    
    public static func create(createdDay: Int? = nil, minute: Int? = nil) -> NotificationCellInfo {
        
        var date = Date.now
        
        if let createdDay {
            date = Calendar.current.date(byAdding: .day, value: createdDay, to: date)!
        }
        
        if let minute {
            date = Calendar.current.date(byAdding: .minute, value: minute, to: date)!
        }
        
        return .init(
            id: UUID().uuidString,
            isRead: false,
            notificationDate: date,
            titleText: "김철수 님이 공고에 지원하였습니다.",
            subTitleText: "서울특별시 강남구 신사동 1등급 78세 여성",
            imageInfo: .init(
                imageURL: .init(string: "https://dummyimage.com/600x400/000/fff")!,
                imageFormat: .png
            )
        )
    }
}
