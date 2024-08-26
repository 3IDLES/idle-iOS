//
//  RecruitmentPostService.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/8/24.
//

import Foundation

public class RecruitmentPostService: BaseNetworkService<RcruitmentPostAPI> {
    
    public init() { }
    
    public override init(keyValueStore: KeyValueStore) {
        super.init(keyValueStore: keyValueStore)
    }
}
