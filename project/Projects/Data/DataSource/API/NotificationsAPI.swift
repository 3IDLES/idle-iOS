//
//  NotificationsAPI.swift
//  DataSource
//
//  Created by choijunios on 10/15/24.
//

import Foundation


import Moya

public enum NotificationsAPI {
    
    case readNotification(id: String)
    case notReadNotificationsCount
    case allNotifications(next: String?)
}

extension NotificationsAPI: BaseAPI {
    
    public var apiType: APIType {
        .notifications
    }
    
    public var path: String {
        switch self {
        case .readNotification(let id):
            "\(id)"
        case .notReadNotificationsCount:
            "count"
        case .allNotifications:
            "my"
        }
    }
    
    
    
    public var method: Moya.Method {
        switch self {
        case .readNotification(let id):
            .patch
        case .notReadNotificationsCount:
            .get
        case .allNotifications:
            .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .allNotifications(let next):
            if let next {
                return .requestParameters(
                    parameters: ["next": next],
                    encoding: URLEncoding.queryString
                )
            }
            return .requestPlain
        default:
            return  .requestPlain
        }
    }
}
