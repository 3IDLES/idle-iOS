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
            
        // TODO: 로컬 맵핑 테스트
        
//        let expectation = expectation(description: "Test function")
//        
//        let repo = AuthService(
//            keyValueStore: TestKeyValueStore()
//        )
//        
//        let disposeBag = DisposeBag()
//        
//        let data = CenterRegistrationDTO(
//            identifier: "test1234",
//            password: "testpassword1234",
//            phoneNumber: "010-4444-5555",
//            managerName: "최준영",
//            centerBusinessRegistrationNumber: "000-00-00000"
//        )
//
//        
//        repo
//            .request(api: .centerLogin(
//                id: "test1234",
//                password: "testpassword1234")
//            )
//            .subscribe { response in
//            
//            print(response)
//            
//            expectation.fulfill()
//        }
//        .disposed(by: disposeBag)
//        
//        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testAuth() {
        
        let repo = DefaultAuthInputValidationRepository()
        
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
