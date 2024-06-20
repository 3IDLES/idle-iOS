//
//  Tests.swift
//  Concrete
//
//  Created by 최준영 on 6/20/24.
//

import XCTest
@testable import Concrete

final class ConcreteTests: XCTestCase {
    
    func testFunction() {
        
        let impl = RepositoryImpl()
        
        let useCase = DefaultUseCase(repository: impl)
        
        useCase.sayHello()
    }
}
