//
//  AppliedPostBoardVM.swift
//  WorkerFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import UseCaseInterface


public class AppliedPostBoardVM: WorkerPagablePostBoardVMable {
    
    // Input
    public var requestInitialPageRequest: RxRelay.PublishRelay<Void> = .init()
    public var requestNextPage: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<(postId: String, postTitle: String)> = .init()
    
    // Output
    public var postBoardData: RxCocoa.Driver<(isRefreshed: Bool, cellData: [PostBoardCellData])>?
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    // Init
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    // Paging
    /// 값이 nil이라면 요청을 보내지 않습니다.
    var nextPagingRequest: PostPagingRequestForWorker?
    /// 가장최신의 데이터를 홀드, 다음 요청시 해당데이터에 새로운 데이터를 더해서 방출
    private let currentPostVO: BehaviorRelay<[NativeRecruitmentPostForWorkerVO]> = .init(value: [])
    
    public init(recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.recruitmentPostUseCase = recruitmentPostUseCase
        self.nextPagingRequest = .initial
        
        let postPageReqeustResult = Observable
            .merge(
                requestInitialPageRequest.asObservable(),
                requestNextPage.asObservable()
            )
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
            .share()
        
        let requestPostListSuccess = postPageReqeustResult.compactMap { $0.value }
        let requestPostListFailure = postPageReqeustResult.compactMap { $0.error }
        
        postBoardData = Observable
            .zip(
                currentPostVO,
                requestPostListSuccess
            )
            .compactMap { [weak self] (prevPostList, fetchedData) -> (Bool, [PostBoardCellData])? in
                
                guard let self else { return nil }
                
                let isRefreshed: Bool = self.nextPagingRequest == .initial
                
                // MARK: 지원 공고의 경우 써드파티에서 불러올 데이터가 없다.
                self.nextPagingRequest = .paging(
                    source: .native,
                    nextPageId: fetchedData.nextPageId
                )
                
                // 화면에 표시할 전체리스트 도출
                let fetchedPosts = fetchedData.posts
                var mergedPosts = currentPostVO.value
                mergedPosts.append(contentsOf: fetchedPosts)
                
                // 최근값 업데이트
                self.currentPostVO.accept(mergedPosts)
                
                // cellData 생성
                let cellData: [PostBoardCellData] = mergedPosts.map { vo in
                    
                    let cardVO: WorkerNativeEmployCardVO = .create(vo: vo)
                    
                    return .init(postId: vo.postId, cardVO: cardVO)
                }
                
                return (isRefreshed, cellData)
            }
            .asDriver(onErrorDriveWith: .never())
        
        alert = requestPostListFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "지원한 공고 불러오기 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    public func showPostDetail(id: String) {
        coordinator?.showPostDetail(postId: id)
    }
}
