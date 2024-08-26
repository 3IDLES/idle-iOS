//
//  DefaultUserInfoLocalRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/26/24.
//

import Foundation
import RxSwift
import Entity
import RepositoryInterface

public class DefaultUserInfoLocalRepository: UserInfoLocalRepository {
    
    
    public func getUserType() -> Entity.UserType? {
        <#code#>
    }
    
    public func updateUserType(_ type: Entity.UserType) {
        <#code#>
    }
    
    public func getCurrentWorkerData() -> Entity.WorkerProfileVO? {
        <#code#>
    }
    
    public func updateCurrentWorkerData(vo: Entity.WorkerProfileVO) {
        <#code#>
    }
    
    public func getCurrentCenterData() -> Entity.CenterProfileVO? {
        <#code#>
    }
}
