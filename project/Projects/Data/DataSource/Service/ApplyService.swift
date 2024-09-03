//
//  ApplyService.swift
//  DataSource
//
//  Created by choijunios on 9/3/24.
//

import Foundation

public class ApplyService: BaseNetworkService<ApplyAPI> {
    
    public init() { }
    
    public override init(keyValueStore: KeyValueStore) {
        super.init(keyValueStore: keyValueStore)
    }
}
