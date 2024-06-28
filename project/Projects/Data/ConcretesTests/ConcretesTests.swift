//
//  Tests.swift
//  Concrete
//
//  Created by 최준영 on 6/20/24.
//

import XCTest
@testable import ConcreteRepository
@testable import NetworkDataSource

final class ConcretesTests: XCTestCase {
    
    func testFunction() {
        
        let expectation = expectation(description: "Test function")
        
        let testStore = TestKeyValueStore()
        
        let testService = DefaultTestService(keyValueStore: testStore)
        
        let single = testService.testRequest()
        
        let _ = single.subscribe { people in
            
            XCTAssertGreaterThanOrEqual(people.count, 1)
            
            expectation.fulfill()
        } onFailure: { error in
            
            XCTFail(error.localizedDescription)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
