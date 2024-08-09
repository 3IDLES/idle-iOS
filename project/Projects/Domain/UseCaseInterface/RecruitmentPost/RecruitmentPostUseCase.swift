//
//  RecruitmentPostUseCase.swift
//  RecruitmentPostUseCase
//
//  Created by choijunios on 8/9/24.
//

import Foundation
import Entity
import RxSwift

public protocol RecruitmentPostUseCase: UseCaseBase {
    
    /// 센터측이 공고를 등록하는 API입니다.
    func registerRecruitmentPost(
        workTimeAndPayStateObject: WorkTimeAndPayStateObject,
        addressInputStateObject: AddressInputStateObject,
        customerInformationStateObject: CustomerInformationStateObject,
        customerRequirementStateObject: CustomerRequirementStateObject,
        applicationDetailStateObject: ApplicationDetailStateObject
    ) -> Single<Result<Void, RecruitmentPostError>>
}
