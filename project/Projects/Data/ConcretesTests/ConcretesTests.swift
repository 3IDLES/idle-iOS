//
//  Tests.swift
//  Concrete
//
//  Created by 최준영 on 6/20/24.
//

import XCTest
@testable import ConcreteRepository
@testable import NetworkDataSource
import RxSwift

final class ConcretesTests: XCTestCase {
    
    func testToken() {
            
        // TODO: 토큰 API구현이후 테스트 코드 작성 예정
        
//        let expectation = expectation(description: "Test function")
//        
//        let testStore = TestKeyValueStore()
//        
//        let testService = DefaultTestService(keyValueStore: testStore)
//        
//        let single = testService.testRequest()
//
//        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testAuth() {
        
        let repo = DefaultCenterRegisterRepository()
        
        let expectation = expectation(description: "center register test")
        
        let disposeBag = DisposeBag()
        
        repo
            .requestPhoneNumberAuthentication(phoneNumber: "000-0000-0000")
            .catch({ error in
                
                XCTFail()
                
                expectation.fulfill()
                
                return .never()
            })
            .subscribe { isSuccess in
                print(isSuccess)
                
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
