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

public class DefaultRecruitmentPostUseCase: RecruitmentPostUseCase {
    
    let repository: RecruitmentPostRepository
    
    public init(repository: RecruitmentPostRepository) {
        self.repository = repository
    }
    
    public func registerRecruitmentPost(inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, RecruitmentPostError>> {
        
        // 마감기간이 지정되지 않는 경우 현재로 부터 한달 후로 설정
        if inputs.applicationDetail.applyDeadlineType == .untilApplicationFinished {
            let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            inputs.applicationDetail.deadlineDate = oneMonthLater
        }
        
        return convert(
            task: repository.registerPost(
                input1: inputs.workTimeAndPay,
                input2: inputs.addressInfo,
                input3: inputs.customerInformation,
                input4: inputs.customerRequirement,
                input5: inputs.applicationDetail
            )
        )
    }
    
    public func getPostDetailForCenter(id: String) -> RxSwift.Single<Result<Entity.RegisterRecruitmentPostBundle, Entity.RecruitmentPostError>> {
        convert(task: repository.getPostDetailForCenter(id: id))
    }
}
