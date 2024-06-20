//
//  RepositoryExample.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 6/21/24.
//

import Foundation
import RepositoryInterface
import NetworkInterface
import Entity

public class DefaultRepository: RepositoryInterface {
    
    let networkDataSource: NetworkDataSource
    
    public init(networkDataSource: NetworkDataSource) {
        self.networkDataSource = networkDataSource
    }
    
    public func getHelloMessage() -> TestEntity {
        
        let str = networkDataSource.reqeust()
        
        return TestEntity(text: str)
    }
}
