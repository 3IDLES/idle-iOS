//
//  RecruitmentPostRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 8/8/24.
//

import Foundation
import RxSwift
import Entity

public protocol RecruitmentPostRepository: RepositoryBase {
    
    // MARK: Center
    func registerPost(
        input1: WorkTimeAndPayStateObject,
        input2: AddressInputStateObject,
        input3: CustomerInformationStateObject,
        input4: CustomerRequirementStateObject,
        input5: ApplicationDetailStateObject
    ) -> Single<Void>
}
