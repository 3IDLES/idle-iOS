//
//  Tests.swift
//  Concrete
//
//  Created by 최준영 on 6/20/24.
//

import XCTest
@testable import ConcreteRepository
@testable import ConcreteNetwork

final class ConcretesTests: XCTestCase {
    
    func testFunction() {
        
        let repository = DefaultRepository(
            networkDataSource: DefaultNetworkDataSource()
        )
        
        print(repository.getHelloMessage())
    }
}
