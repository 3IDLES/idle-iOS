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
    
    public func registerRecruitmentPost(inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, DomainError>> {
        
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
    
    public func editRecruitmentPost(id: String, inputs: Entity.RegisterRecruitmentPostBundle) -> RxSwift.Single<Result<Void, Entity.DomainError>> {
        
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
    
    public func getPostDetailForCenter(id: String) -> RxSwift.Single<Result<Entity.RegisterRecruitmentPostBundle, Entity.DomainError>> {
        convert(task: repository.getPostDetailForCenter(id: id))
    }
    
    public func getPostDetailForWorker(id: String) -> RxSwift.Single<Result<Entity.RecruitmentPostForWorkerBundle, Entity.DomainError>> {
        convert(task: repository.getPostDetailForWorker(id: id))
    }
    
    public func getOngoingPosts() -> RxSwift.Single<Result<[Entity.RecruitmentPostInfoForCenterVO], Entity.DomainError>> {
        let task = repository
            .getOngoingPosts()
            .map { postInfo in
                postInfo.forEach { vo in vo.state = .onGoing }
                return postInfo
            }
        return convert(task: task)
    }
    
    public func getClosedPosts() -> RxSwift.Single<Result<[Entity.RecruitmentPostInfoForCenterVO], Entity.DomainError>> {
        let task = repository
            .getClosedPosts()
            .map { postInfo in
                postInfo.forEach { vo in vo.state = .closed }
                return postInfo
            }
        return convert(task: task)
    }
    
    public func closePost(id: String) -> Single<Result<Void, DomainError>> {
        convert(task: repository.closePost(id: id))
    }
    
    public func removePost(id: String) -> Single<Result<Void, DomainError>> {
        convert(task: repository.removePost(id: id))
    }
    
    public func getPostApplicantCount(id: String) -> RxSwift.Single<Result<Int, Entity.DomainError>> {
        convert(task: repository.getPostApplicantCount(id: id))
    }
    
    public func getPostApplicantScreenData(id: String) -> RxSwift.Single<Result<Entity.PostApplicantScreenVO, Entity.DomainError>> {
        convert(task: repository.getPostApplicantScreenData(id: id))
    }
    
    public func getPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>> {
        
        let stream: Single<RecruitmentPostListForWorkerVO>!
        
        switch request {
        case .native(let nextPageId):
            stream = repository.getNativePostListForWorker(
                nextPageId: nextPageId,
                requestCnt: postCount
            )
        case .thirdParty(let nextPageId):
            /// 워크넷 가져오기 미구현
            fatalError()
        }
        
        return convert(task: stream)
    }
    
    public func getFavoritePostListForWorker(pageId: String?, postCount: Int) -> RxSwift.Single<Result<Entity.RecruitmentPostListForWorkerVO, Entity.DomainError>> {
        convert(task: repository.getFavoritePostListForWorker(
            nextPageId: pageId,
            requestCnt: postCount
        ))
    }
    
    public func getAppliedPostListForWorker(pageId: String?, postCount: Int) -> RxSwift.Single<Result<Entity.RecruitmentPostListForWorkerVO, Entity.DomainError>> {
        convert(task: repository.getAppliedPostListForWorker(
            nextPageId: pageId,
            requestCnt: postCount
        ))
    }
}
