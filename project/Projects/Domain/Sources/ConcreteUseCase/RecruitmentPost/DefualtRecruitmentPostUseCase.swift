//
//  DefualtRecruitmentPostUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/9/24.
//

import Foundation


import RxSwift

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
    
    public func editRecruitmentPost(id: String, inputs: RegisterRecruitmentPostBundle) -> RxSwift.Single<Result<Void, DomainError>> {
        
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
    
    public func getPostDetailForCenter(id: String) -> RxSwift.Single<Result<RegisterRecruitmentPostBundle, DomainError>> {
        convert(task: repository.getPostDetailForCenter(id: id))
    }
    
    public func getNativePostDetailForWorker(id: String) -> RxSwift.Single<Result<RecruitmentPostForWorkerBundle, DomainError>> {
        convert(task: repository.getNativePostDetailForWorker(id: id))
    }
    
    public func getWorknetPostDetailForWorker(id: String) -> RxSwift.Single<Result<WorknetRecruitmentPostDetailVO, DomainError>> {
        convert(task: repository.getWorknetPostDetailForWorker(id: id))
    }
    
    public func getOngoingPosts() -> RxSwift.Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>> {
        let task = repository
            .getOngoingPosts()
            .map { postInfo in
                postInfo.forEach { vo in vo.state = .onGoing }
                return postInfo
            }
        return convert(task: task)
    }
    
    public func getClosedPosts() -> RxSwift.Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>> {
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
    
    public func getPostApplicantCount(id: String) -> RxSwift.Single<Result<Int, DomainError>> {
        convert(task: repository.getPostApplicantCount(id: id))
    }
    
    public func getPostApplicantScreenData(id: String) -> RxSwift.Single<Result<PostApplicantScreenVO, DomainError>> {
        convert(task: repository.getPostApplicantScreenData(id: id))
    }
    
    public func getPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>> {
        
        let stream: Single<RecruitmentPostListForWorkerVO>!
        
        switch request {
        case .initial:
            stream = repository.getNativePostListForWorker(
                nextPageId: nil,
                requestCnt: postCount
            )
        case .paging(let source, let nextPageId):
            switch source {
            case .native:
                stream = repository.getNativePostListForWorker(
                    nextPageId: nextPageId,
                    requestCnt: postCount
                )
            case .thirdParty:
                stream = repository.getWorknetPostListForWorker(
                    nextPageId: nextPageId,
                    requestCnt: postCount
                )
            }
        }
        
        return convert(task: stream)
    }
    
    public func getFavoritePostListForWorker() -> RxSwift.Single<Result<[RecruitmentPostForWorkerRepresentable], DomainError>> {
        
        let nativeList = repository.getNativeFavoritePostListForWorker()
        let worknetList = repository.getWorknetFavoritePostListForWorker()
        
        let task = Single
            .zip(nativeList, worknetList)
            .map { (native, worknet) in
                native + worknet
            }
        
        return convert(task: task)
    }
    
    public func getAppliedPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> RxSwift.Single<Result<RecruitmentPostListForWorkerVO, DomainError>> {
        
        let stream: Single<RecruitmentPostListForWorkerVO>!
        
        switch request {
        case .initial:
            stream = repository.getAppliedPostListForWorker(
                nextPageId: nil,
                requestCnt: postCount
            )
        case .paging(let source, let nextPageId):
            switch source {
            case .native:
                stream = repository.getAppliedPostListForWorker(
                    nextPageId: nextPageId,
                    requestCnt: postCount
                )
            case .thirdParty:
                // Presentation에서 에초에 호출하지 않음
                return .just(.failure(.undefinedCode))
            }
        }
        
        return convert(task: stream)
    }
    
    public func applyToPost(postId: String, method: ApplyType) -> RxSwift.Single<Result<Void, DomainError>> {
        convert(task: repository.applyToPost(postId: postId, method: method))
    }
    
    public func addFavoritePost(postId: String, type: RecruitmentPostType) -> Single<Result<Void, DomainError>> {
        convert(task: repository.addFavoritePost(postId: postId, type: type))
    }
    
    public func removeFavoritePost(postId: String) -> Single<Result<Void, DomainError>> {
        convert(task: repository.removeFavoritePost(postId: postId))
    }
}
