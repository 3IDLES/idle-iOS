//
//  DefualtRecruitmentPostUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/9/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefualtRecruitmentPostUseCase: RecruitmentPostUseCase {
    
    let repository: RecruitmentPostRepository
    
    public init(repository: RecruitmentPostRepository) {
        self.repository = repository
    }
    
    public func registerRecruitmentPost(
        workTimeAndPayStateObject: Entity.WorkTimeAndPayStateObject,
        addressInputStateObject: AddressInputStateObject,
        customerInformationStateObject: CustomerInformationStateObject,
        customerRequirementStateObject: CustomerRequirementStateObject,
        applicationDetailStateObject: ApplicationDetailStateObject
    ) -> Single<Result<Void, RecruitmentPostError>> {
        
        convert(
            task: repository.registerPost(
                input1: workTimeAndPayStateObject,
                input2: addressInputStateObject,
                input3: customerInformationStateObject,
                input4: customerRequirementStateObject,
                input5: applicationDetailStateObject
            )
            .map({ _ in Void() }) ) { [unowned self] error in
                toDomainError(error: error)
        }
    }
}
