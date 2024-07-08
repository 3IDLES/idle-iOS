//
//  Tests.swift
//  Concrete
//
//  Created by 최준영 on 6/20/24.
//

import XCTest
@testable import ConcreteUseCase
@testable import ConcreteRepository
@testable import NetworkDataSource

final class ConcreteTests: XCTestCase {
    
    func testPhoneNumberRegex() {
        
        let usecase = DefaultCenterRegisterUseCase(
            repository: DefaultCenterRegisterRepository(
                networkService: CenterRegisterService()
            )
        )
        
        let result1 = usecase.checkPhoneNumberIsValid(
            phoneNumber: "01012341234"
        )
        print(result1)
        XCTAssertTrue(result1, "✅ 올바른 번호 성공")
        
        let result2 = usecase.checkPhoneNumberIsValid(
            phoneNumber: "0101234123213"
        )
        
        XCTAssertFalse(result2, "✅ 올바른 번호 실패")
        
        let result3 = usecase.checkPhoneNumberIsValid(
            phoneNumber: "안녕하세요"
        )
        
        XCTAssertFalse(result3, "✅ 올바른 번호 실패")
    }
}
