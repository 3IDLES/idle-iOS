//
//  NotificationTokenTransferService.swift
//  DataSource
//
//  Created by choijunios on 10/8/24.
//

import Foundation


public protocol NotificationTokenTransferService: NetworkService where TagetAPI == NotificationTokenAPI { }

public class DefaultNotificationTokenTransferService: BaseNetworkService<NotificationTokenAPI>, NotificationTokenTransferService { }
