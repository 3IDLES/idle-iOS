//
//  ExternalRequestService.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public class ExternalRequestService: BaseNetworkService<ExtenalUrlAPI> {
    
    public init() { }
    
    public override init(keyValueStore: KeyValueStore) {
        super.init(keyValueStore: keyValueStore)
    }
}
