//
//  DefualtRecruitmentPostUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/9/24.
//

import Foundation
import Core

import RxSwift

public class DefaultRecruitmentPostUseCase: RecruitmentPostUseCase {
    
    @Injected var repository: RecruitmentPostRepository
    
    public init() { }
    
    public func registerRecruitmentPost(inputs: RegisterRecruitmentPostBundle) -> Single<Result<Void, DomainError>> {
        
        // 마감기간이 지정되지 않는 경우 현재로 부터 한달 후로 설정
        if inputs.applicationDetail.applyDeadlineType == .untilApplicationFinished {
            let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            inputs.applicationDetail.deadlineDate = oneMonthLater
        }
        
        return repository.registerPost(bundle: inputs)
    }
    
    public func editRecruitmentPost(id: String, inputs: RegisterRecruitmentPostBundle) -> RxSwift.Single<Result<Void, DomainError>> {
        
        if inputs.applicationDetail.applyDeadlineType == .untilApplicationFinished {
            let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            inputs.applicationDetail.deadlineDate = oneMonthLater
        }
        
        return repository.editPostDetail(id: id, bundle: inputs)
    }
    
    public func getPostDetailForCenter(id: String) -> RxSwift.Single<Result<RegisterRecruitmentPostBundle, DomainError>> {
        repository.getPostDetailForCenter(id: id)
    }
    
    public func getNativePostDetailForWorker(id: String) -> RxSwift.Single<Result<RecruitmentPostForWorkerBundle, DomainError>> {
        repository.getNativePostDetailForWorker(id: id)
    }
    
    public func getWorknetPostDetailForWorker(id: String) -> RxSwift.Single<Result<WorknetRecruitmentPostDetailVO, DomainError>> {
        repository.getWorknetPostDetailForWorker(id: id)
    }
    
    public func getOngoingPosts() -> Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>> {
        
        repository
            .getOngoingPosts()
            .map { result -> Result<[RecruitmentPostInfoForCenterVO], DomainError> in
                
                if case .success(let postInfos) = result {
                    
                    return .success(postInfos.map { $0.setState(.onGoing) })
                }
                return result
            }
    }
    
    public func getClosedPosts() -> RxSwift.Single<Result<[RecruitmentPostInfoForCenterVO], DomainError>> {
        
        repository
            .getClosedPosts()
            .map { result -> Result<[RecruitmentPostInfoForCenterVO], DomainError> in
                
                if case .success(let postInfos) = result {
                    
                    return .success(postInfos.map { $0.setState(.closed) })
                }
                return result
            }
    }
    
    public func closePost(id: String) -> Single<Result<Void, DomainError>> {
        repository.closePost(id: id)
    }
    
    public func removePost(id: String) -> Single<Result<Void, DomainError>> {
        repository.removePost(id: id)
    }
    
    public func getPostApplicantCount(id: String) -> RxSwift.Single<Result<Int, DomainError>> {
        repository.getPostApplicantCount(id: id)
    }
    
    public func getPostApplicantScreenData(id: String) -> RxSwift.Single<Result<PostApplicantScreenVO, DomainError>> {
        repository.getPostApplicantScreenData(id: id)
    }
    
    public func getPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> Single<Result<RecruitmentPostListForWorkerVO, DomainError>> {
        
        let stream: Single<Result<RecruitmentPostListForWorkerVO, DomainError>>!
        
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
        
        return stream
    }
    
    public func getFavoritePostListForWorker() -> RxSwift.Single<Result<[RecruitmentPostForWorkerRepresentable], DomainError>> {
        
        let fetchNativeListResult = repository.getNativeFavoritePostListForWorker()
        let nativeSuccess = fetchNativeListResult.compactMap { $0.value }
        let nativeFailure = fetchNativeListResult.compactMap { $0.error }
        
        let fetchWorknetListResult = repository
            .getWorknetFavoritePostListForWorker()
            .asObservable()
            .share()
        let worknetSuccess = fetchWorknetListResult.compactMap { $0.value }
        let worknetFailure = fetchWorknetListResult.compactMap { $0.error }
        
        
        let successZip = Observable
            .zip(nativeSuccess.asObservable(), worknetSuccess.asObservable())
            .map { (native, worknet) -> Result<[RecruitmentPostForWorkerRepresentable], DomainError> in
                .success(native + worknet)
            }
        
        let failureMerge = Observable
            .merge(nativeFailure.asObservable(), worknetFailure.asObservable())
            .map { error -> Result<[RecruitmentPostForWorkerRepresentable], DomainError> in
                .failure(error)
            }
        
        return Observable
            .merge(successZip, failureMerge)
            .asSingle()
    }
    
    public func getAppliedPostListForWorker(request: PostPagingRequestForWorker, postCount: Int) -> RxSwift.Single<Result<RecruitmentPostListForWorkerVO, DomainError>> {
        
        let stream: Single<Result<RecruitmentPostListForWorkerVO, DomainError>>!
        
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
        
        return stream
    }
    
    public func applyToPost(postId: String, method: ApplyType) -> RxSwift.Single<Result<Void, DomainError>> {
        repository.applyToPost(postId: postId, method: method)
    }
    
    public func addFavoritePost(postId: String, type: PostOriginType) -> Single<Result<Void, DomainError>> {
        repository.addFavoritePost(postId: postId, type: type)
    }
    
    public func removeFavoritePost(postId: String) -> Single<Result<Void, DomainError>> {
        repository.removeFavoritePost(postId: postId)
    }
}
