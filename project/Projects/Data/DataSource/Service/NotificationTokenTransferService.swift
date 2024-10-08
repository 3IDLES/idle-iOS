//
//  NotificationTokenTransferService.swift
//  DataSource
//
//  Created by choijunios on 10/8/24.
//

import Foundation

public class NotificationTokenTransferService: BaseNetworkService<NotificationTokenAPI> {
    
    public init() { }
    
    public override init(keyValueStore: KeyValueStore) {
        super.init(keyValueStore: keyValueStore)
    }
}
