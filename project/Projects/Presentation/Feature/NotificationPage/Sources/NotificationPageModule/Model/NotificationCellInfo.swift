//
//  NotificationCellInfo.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import Foundation
import Entity

struct NotificationCellInfo {
    
    let id: String
    let isRead: Bool
    
    let timeText: String
    let titleText: String
    let subTitleText: String
    let imageInfo: ImageDownLoadInfo
}
