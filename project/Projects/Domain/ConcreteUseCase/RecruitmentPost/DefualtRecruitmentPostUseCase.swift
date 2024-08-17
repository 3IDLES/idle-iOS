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
                bundle: inputs
            )
        )
    }
    
    public func editRecruitmentPost(id: String, inputs: Entity.RegisterRecruitmentPostBundle) -> RxSwift.Single<Result<Void, Entity.RecruitmentPostError>> {
        
        if inputs.applicationDetail.applyDeadlineType == .untilApplicationFinished {
            let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            inputs.applicationDetail.deadlineDate = oneMonthLater
        }
        
        return convert(
            task: repository.editPostDetail(
                id: id,
                bundle: inputs
            )
        )
    }
    
    public func getPostDetailForCenter(id: String) -> RxSwift.Single<Result<Entity.RegisterRecruitmentPostBundle, Entity.RecruitmentPostError>> {
        convert(task: repository.getPostDetailForCenter(id: id))
    }
    
    public func getPostDetailForWorker(id: String) -> RxSwift.Single<Result<Entity.RecruitmentPostForWorkerBundle, Entity.RecruitmentPostError>> {
        convert(task: repository.getPostDetailForWorker(id: id))
    }
    
    public func getPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, RecruitmentPostError>> {
        
        let stream: Single<RecruitmentPostListForWorkerVO>!
        
        switch request {
        case .native(let nextPageId):
            stream = repository.getNativePostListForWorker(
                nextPageId: nextPageId,
                requestCnt: postCount
            )
        case .thirdParty(let nextPageId):
            /// 미구현
            fatalError()
        }
        
        return convert(task: stream)
    }
}
