//
//  DefaultUserInfoLocalRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/26/24.
//

import Foundation
import DataSource
import Domain


import RxSwift

/// 저장된 데이터의 키값을 나타냅니다.
enum UserInfoStorageKey: String, Hashable, CaseIterable {
    // UserType
    case userType = "userType"
    
    // Worker
    case currentWorker = "currentWorker"
    
    // Center
    case currentCenter = "currentCenter"
    case currentCenterAuthState = "currentCenterAuthState"
}

public class DefaultUserInfoLocalRepository: UserInfoLocalRepository {
    
    typealias K = UserInfoStorageKey
    
    let localStorageService: LocalStorageService
    
    let jsonDecoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public init(
        localStorageService: LocalStorageService
    ) {
        self.localStorageService = localStorageService
    }
    
    public func getUserType() -> UserType? {
        let rawValue: String? = localStorageService.fetchData(key: K.userType.rawValue)
        if let rawValue {
            return UserType(rawValue: rawValue)
        }
        return nil
    }
    
    public func updateUserType(_ type: UserType) {
        localStorageService.saveData(
            key: K.userType.rawValue,
            value: type.rawValue
        )
    }
    
    public func getCurrentWorkerData() -> WorkerProfileVO? {
        if let data: Data = localStorageService.fetchData(key: K.currentWorker.rawValue) {
            
            if let decoded = try? jsonDecoder.decode(WorkerProfileVO.self, from: data) {
                
                return decoded
            }
        }
        return nil
    }
    
    public func updateCurrentWorkerData(vo: WorkerProfileVO) {
        let encoded = try! encoder.encode(vo)
        localStorageService.saveData(key: K.currentWorker.rawValue, value: encoded)
    }
    
    public func getCurrentCenterData() -> CenterProfileVO? {
        if let data: Data = localStorageService.fetchData(key: K.currentCenter.rawValue) {
            
            if let decoded = try? jsonDecoder.decode(CenterProfileVO.self, from: data) {
                
                return decoded
            }
        }
        return nil
    }
    
    public func updateCurrentCenterData(vo: CenterProfileVO) {
        let encoded = try! encoder.encode(vo)
        localStorageService.saveData(key: K.currentCenter.rawValue, value: encoded)
    }
    
    public func removeAllData() {
        
        UserInfoStorageKey.allCases.forEach { key in
            localStorageService.remove(key: key.rawValue)
        }
    }
}
