//
//  TokenTesting.swift
//  ConcreteRepository
//
//  Created by choijunios on 6/28/24.
//

import Foundation
import RxSwift
@testable import NetworkDataSource

// TestKeyValueStore
class TestKeyValueStore: KeyValueStore {
    
    init(testStore: [String : String] = [:]) {
        self.testStore = [
            Key.Auth.kaccessToken: "access_token",
            Key.Auth.krefreshToken: "refresh_token",
        ].merging(testStore, uniquingKeysWith: { $1 })
    }
    
    var testStore: [String: String] = [:]
    
    func save(key: String, value: String) throws {
        
        testStore[key] = value
    }
    
    func get(key: String) -> String? {
        
        return testStore[key]
    }
    
    func delete(key: String) throws {
        
        testStore.removeValue(forKey: key)
    }
    
    func removeAll() throws {
        
        testStore.removeAll()
    }
}

// TestAPI
public enum TestAPI: BaseAPI {
    
    public static let apiType: APIType = .test
    
    case testEndPoint
    
    public var method: ReqeustConponents.HTTPMethod { .get }
    
    public var headers: [String: String] {
       
        var myHeader = defaultHeaders
        
        myHeader[ReqeustConponents.Header.authorization.key] = ReqeustConponents.Header.authorization.defaultValue
        
        return myHeader
    }
    
    public var endPoint: String {
        
        switch self {
        case .testEndPoint:
            return ""
        }
    }
}

protocol TestService {
    
    func testRequest() -> Single<[Person]>
}

class DefaultTestService: BaseNetworkService<TestAPI> { }

extension DefaultTestService: TestService {
    
    func testRequest() -> Single<[Person]> {
        
        request(api: .testEndPoint)
    }
}

struct Person: Codable {
    let name: String
    let age: String
    let id: String
}
