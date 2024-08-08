//
//  Default.swift
//  ConcreteRepository
//
//  Created by choijunios on 8/8/24.
//

import RepositoryInterface
import RxSwift
import Entity

public class DefaultRecruitmentPostRepository: RecruitmentPostRepository {
    
    public func registerPost(input1: Entity.WorkTimeAndPayStateObject, input2: Entity.AddressInputStateObject, input3: Entity.CustomerInformationStateObject, input4: Entity.CustomerRequirementStateObject, input5: Entity.ApplicationDetailStateObject) -> RxSwift.Single<Void> {
        
        
        return .just(())
    }
}

    
    
