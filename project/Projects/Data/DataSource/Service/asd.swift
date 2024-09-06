//
//  CrawlingPostService.swift
//  DataSource
//
//  Created by choijunios on 9/6/24.
//

import Foundation

public class CrawlingPostService: BaseNetworkService<CrawlingPostAPI> {
    
    public init() { }
    
    public override init(keyValueStore: KeyValueStore) {
        super.init(keyValueStore: keyValueStore)
    }
}
