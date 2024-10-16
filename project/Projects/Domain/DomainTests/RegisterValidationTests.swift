//
//  RegisterValidationTests.swift
//  DomainTests
//
//  Created by choijunios on 10/16/24.
//

import Foundation
import XCTest
import Core

@testable import Domain
@testable import Testing

final class RegisterValidationTests: XCTestCase {
    
    static override func setUp() {
        DependencyInjector.shared.assemble(MockAssemblies)
    }
    
    func testPhoneNumberRegex() {
        
        let usecase = DefaultAuthInputValidationUseCase()
        
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
    
    // MARK: Id & Password
    
    func testValidId() {
        
        let usecase = DefaultAuthInputValidationUseCase()
        
        // 유효한 아이디 테스트
        XCTAssertTrue(usecase.checkIdIsValid(id: "User123"))
        XCTAssertTrue(usecase.checkIdIsValid(id: "user12"))
        XCTAssertTrue(usecase.checkIdIsValid(id: "123456"))
        XCTAssertTrue(usecase.checkIdIsValid(id: "abcdef"))
        XCTAssertTrue(usecase.checkIdIsValid(id: "ABCDEF"))
    }
    
    func testInvalidId() {
        
        let usecase = DefaultAuthInputValidationUseCase()
        
        // 유효하지 않은 아이디 테스트
        XCTAssertFalse(usecase.checkIdIsValid(id: "Us3!")) // 너무 짧음
        XCTAssertFalse(usecase.checkIdIsValid(id: "user@123")) // 특수 문자 포함
        XCTAssertFalse(usecase.checkIdIsValid(id: "123456789012345678901")) // 너무 길음
        XCTAssertFalse(usecase.checkIdIsValid(id: "user name")) // 공백 포함
    }
    
    func testValidPassword() {
        
        let usecase = DefaultAuthInputValidationUseCase()
        
        // 유효한 비밀번호 테스트
        XCTAssertTrue(usecase.checkPasswordIsValid(password: "Password1"))
        XCTAssertTrue(usecase.checkPasswordIsValid(password: "pass1234"))
        XCTAssertTrue(usecase.checkPasswordIsValid(password: "1234Abcd!"))
        XCTAssertTrue(usecase.checkPasswordIsValid(password: "Valid123"))
        XCTAssertTrue(usecase.checkPasswordIsValid(password: "StrongPass1!"))
    }
    
    func testInvalidPassword() {
        
        let usecase = DefaultAuthInputValidationUseCase()
        
        // 유효하지 않은 비밀번호 테스트
        XCTAssertFalse(usecase.checkPasswordIsValid(password: "short1")) // 너무 짧음
        XCTAssertFalse(usecase.checkPasswordIsValid(password: "alllowercase")) // 숫자 없음
        XCTAssertFalse(usecase.checkPasswordIsValid(password: "ALLUPPERCASE")) // 숫자 없음
        XCTAssertFalse(usecase.checkPasswordIsValid(password: "12345678")) // 영문자 없음
        XCTAssertFalse(usecase.checkPasswordIsValid(password: "123456789012345678901")) // 너무 길음
    }
}
