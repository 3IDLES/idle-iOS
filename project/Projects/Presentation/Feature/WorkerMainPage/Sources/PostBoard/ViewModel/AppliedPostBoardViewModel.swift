//
//  AppliedPostBoardVM.swift
//  WorkerFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit
import Core


import RxCocoa
import RxSwift


class AppliedPostBoardViewModel: BaseViewModel, WorkerPagablePostBoardVMable {
    
    // Injected
    @Injected var recruitmentPostUseCase: RecruitmentPostUseCase
    
    // Navigation
    var presentPostDetailPage: ((String, PostOriginType) -> ())?
    
    // Input
    var requestInitialPageRequest: RxRelay.PublishRelay<Void> = .init()
    var requestNextPage: RxRelay.PublishRelay<Void> = .init()
    var applyButtonClicked: RxRelay.PublishRelay<(postId: String, postTitle: String)> = .init()
    
    // Output
    var postBoardData: RxCocoa.Driver<BoardRefreshResult>?
    
    // Paging
    /// 값이 nil이라면 요청을 보내지 않습니다.
    var nextPagingRequest: PostPagingRequestForWorker?
    /// 가장최신의 데이터를 홀드, 다음 요청시 해당데이터에 새로운 데이터를 더해서 방출
    private let currentPostVO: BehaviorRelay<[RecruitmentPostForWorkerRepresentable]> = .init(value: [])
    
    override init() {
        self.nextPagingRequest = .initial
        
        super.init()
        
        var loadingStartObservables: [Observable<Void>] = []
        var loadingEndObservables: [Observable<Void>] = []
        
        // MARK: 공고리스트 처음부터 요청하기
        let initialRequest = requestInitialPageRequest
            .flatMap { [weak self, recruitmentPostUseCase] request in
                
                self?.currentPostVO.accept([])
                self?.nextPagingRequest = .initial
                
                return recruitmentPostUseCase
                    .getAppliedPostListForWorker(
                        request: .initial,
                        postCount: 10
                    )
            }
            .share()
        
        // 로딩 시작
        loadingStartObservables.append(initialRequest.map { _ in })
        
        // MARK: 공고리스트 페이징 요청
        let pagingRequest = requestNextPage
            .compactMap { [weak self] _ in
                // 요청이 없는 경우 요청을 보내지 않는다.
                // ThirdPatry에서도 불러올 데이터가 없는 경우입니다.
                self?.nextPagingRequest
            }
            .flatMap { [recruitmentPostUseCase] request in
                recruitmentPostUseCase
                    .getAppliedPostListForWorker(
                        request: request,
                        postCount: 10
                    )
            }
            
        let postPageReqeustResult = Observable
            .merge(initialRequest, pagingRequest)
            .share()
        
        // 로딩 종료
        loadingEndObservables.append(postPageReqeustResult.map { _ in })
        
        let requestPostListSuccess = postPageReqeustResult.compactMap { $0.value }
        let requestPostListFailure = postPageReqeustResult.compactMap { $0.error }
        
        postBoardData = Observable
            .zip(
                currentPostVO,
                requestPostListSuccess
            )
            .compactMap { [weak self] (prevPostList, fetchedData) -> BoardRefreshResult? in
                
                guard let self else { return nil }
                
                let isRefreshed: Bool = self.nextPagingRequest == .initial
                
                
                if let next = fetchedData.nextPageId {
                    // 지원 공고의 경우 써드파티에서 불러올 데이터가 없다.
                    self.nextPagingRequest = .paging(
                        source: .native,
                        nextPageId: next
                    )
                } else {
                    self.nextPagingRequest = nil
                }
                
                
                // 화면에 표시할 전체리스트 도출
                let fetchedPosts = fetchedData.posts
                var mergedPosts = currentPostVO.value
                mergedPosts.append(contentsOf: fetchedPosts)
                
                // 최근값 업데이트
                self.currentPostVO.accept(mergedPosts)
                
                return (isRefreshed, mergedPosts)
            }
            .asDriver(onErrorDriveWith: .never())
        
        requestPostListFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "지원한 공고 불러오기 오류",
                    message: error.message
                )
            }
            .subscribe(self.alert)
            .disposed(by: disposeBag)
        
        // MARK: 로딩
        Observable
            .merge(loadingStartObservables)
            .subscribe(self.showLoading)
            .disposed(by: disposeBag)
        
        Observable
            .merge(loadingEndObservables)
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(self.dismissLoading)
            .disposed(by: disposeBag)
    }
    
    func showPostDetail(postType: Domain.PostOriginType, id: String) {
        self.presentPostDetailPage?(id, postType)
    }
}
