//
//  SaveUserInfoDataTests.swift
//  ConcretesTests
//
//  Created by choijunios on 8/26/24.
//

import Foundation
import XCTest
import Core


@testable import Repository
@testable import DataSource
@testable import Testing

class SaveUserInfoDataTests: XCTestCase {
    
    static override func setUp() {
        DependencyInjector.shared.assemble(MockAssemblies)
    }
    
    func testUserTypeCRUD() {
        
        let repository = DefaultUserInfoLocalRepository()
        
        var userType = repository.getUserType()
        
        XCTAssertNil(userType)
        
        repository.updateUserType(.center)
        
        userType = repository.getUserType()
        
        XCTAssertEqual(userType, .center)
        
        repository.updateUserType(.worker)
        
        userType = repository.getUserType()
        
        XCTAssertEqual(userType, .worker)
        
        repository.removeAllData()
        
        userType = repository.getUserType()
        
        XCTAssertNil(userType)
    }
    
    func testUserInfoCRUD() {
        
        // MARK: Center
        let repository = DefaultUserInfoLocalRepository()
        
        var centerInfo = repository.getCurrentCenterData()
        
        XCTAssertNil(centerInfo)
        
        repository.updateCurrentCenterData(
            vo: .init(
                centerName: "test",
                officeNumber: "test",
                roadNameAddress: "test",
                lotNumberAddress: "test",
                detailedAddress: "test",
                longitude: "test",
                latitude: "test",
                introduce: "test",
                profileImageInfo: nil
            )
        )
        
        centerInfo = repository.getCurrentCenterData()
        
        XCTAssertNotNil(centerInfo)
        XCTAssertEqual(centerInfo?.centerName, "test")
        
        repository.removeAllData()
        
        centerInfo = repository.getCurrentCenterData()
        
        XCTAssertNil(centerInfo)
        
        // MARK: Worker
        
        var workerInfo = repository.getCurrentWorkerData()
        
        XCTAssertNil(workerInfo)
        
        repository.updateCurrentWorkerData(
            vo: .init(
                profileImageInfo: nil,
                nameText: "test",
                phoneNumber: "test",
                isLookingForJob: true,
                age: 123,
                gender: .female,
                expYear: nil,
                address: .init(roadAddress: "test", jibunAddress: "test"),
                introductionText: "test",
                specialty: "test",
                longitude: 0.0,
                latitude: 0.0
            )
        )
        
        workerInfo = repository.getCurrentWorkerData()
        
        XCTAssertNotNil(workerInfo)
        XCTAssertEqual(workerInfo?.age, 123)
        
        repository.removeAllData()
        
        workerInfo = repository.getCurrentWorkerData()
        
        XCTAssertNil(workerInfo)
    }
}
