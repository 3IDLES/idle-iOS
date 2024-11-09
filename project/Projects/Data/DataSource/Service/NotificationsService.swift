//
//  NotificationsService.swift
//  DataSource
//
//  Created by choijunios on 10/15/24.
//

import Foundation

public protocol NotificationsService: NetworkService where TagetAPI == NotificationsAPI { }

public class DefaultNotificationsService: BaseNetworkService<NotificationsAPI>, NotificationsService { }
