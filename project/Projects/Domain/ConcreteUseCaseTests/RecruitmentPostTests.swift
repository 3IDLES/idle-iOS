//
//  RecruitmentPostTests.swift
//  ConcreteUseCaseTests
//
//  Created by choijunios on 8/9/24.
//

import XCTest
import RxSwift
@testable import ConcreteUseCase
@testable import ConcreteRepository
@testable import NetworkDataSource

/// 사용자의 입력을 판단하는 UseCase를 테스트 합니다.
final class RecruitmentPostTests: XCTestCase {
    
    let authUseCase = DefaultAuthUseCase(
        repository: DefaultAuthRepository()
    )
    
    let postUseCase = DefualtRecruitmentPostUseCase(
        repository: DefaultRecruitmentPostRepository()
    )
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        
        let expectation = XCTestExpectation(description: "로그인")
        
        // #1. 로그인
        let tesId = "test123458123"
        let testPassword = "testpassword1234"

        authUseCase.loginCenterAccount(
            id: tesId,
            password: testPassword
        )
        .subscribe(onSuccess: { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail()
            }
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0) // 이 위치에서 작업이 완료될 때
    }
    
    func testRegisterPostRecruitment() {
        
        let expectation = XCTestExpectation(description: "공고등록")
        
        postUseCase
            .registerRecruitmentPost(
                workTimeAndPayStateObject: .mock,
                addressInputStateObject: .mock,
                customerInformationStateObject: .mock,
                customerRequirementStateObject: .mock,
                applicationDetailStateObject: .mock
            )
            .subscribe(onSuccess: { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    print(error)
                    XCTFail()
                }
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0) // 이 위치에서 작업이 완료될 때
    }
}
