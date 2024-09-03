//
//  WorkerRecruitmentPostBoardVM.swift
//  WorkerFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import UseCaseInterface

public protocol WorkerPagablePostBoardVMable: DefaultAlertOutputable {
    /// 다음 페이지를 요청합니다.
    var requestNextPage: PublishRelay<Void> { get }
    /// 화면이 등장할 때마다 리스트를 초기화합니다.
    var requestInitialPageRequest: PublishRelay<Void> { get }
    
    /// 페이지요청에 대한 결과를 전달합니다.
    var postBoardData: Driver<[WorkerEmployCardViewModelable]>? { get }
}

public protocol WorkerRecruitmentPostBoardVMable: WorkerPagablePostBoardVMable {
    
    /// 요양보호사 위치정보를 요청합니다.
    var requestWorkerLocation: PublishRelay<Void> { get }
    
    /// 요양보호사 위치 정보를 전달합니다.
    var workerLocationTitleText: Driver<String>? { get }
}

public class WorkerRecruitmentPostBoardVM: WorkerRecruitmentPostBoardVMable {
    
    // Output
    public var postBoardData: Driver<[WorkerEmployCardViewModelable]>?
    public var alert: Driver<DefaultAlertContentVO>?
    public var workerLocationTitleText: Driver<String>?
    
    
    // Input
    public var requestInitialPageRequest: PublishRelay<Void> = .init()
    public var requestWorkerLocation: PublishRelay<Void> = .init()
    public var requestNextPage: PublishRelay<Void> = .init()
    
    
    // Init
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    // Paging
    /// 값이 nil이라면 요청을 보내지 않습니다.
    var nextPagingRequest: PostPagingRequestForWorker? = .initial
    /// 가장최신의 데이터를 홀드, 다음 요청시 해당데이터에 새로운 데이터를 더해서 방출
    private let currentPostVO: BehaviorRelay<[NativeRecruitmentPostForWorkerVO]> = .init(value: [])
    
    // Observable
    let dispostBag = DisposeBag()
    
    public init(
        coordinator: WorkerRecruitmentBoardCoordinatable,
        recruitmentPostUseCase: RecruitmentPostUseCase
        )
    {
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        // 상단 위치정보
        workerLocationTitleText = requestWorkerLocation
            .compactMap { [weak self] _ in
                self?.fetchWorkerLocation()
            }
            .asDriver(onErrorJustReturn: "위치정보확인불가")
        
        
        let initialRequest = requestInitialPageRequest
            .flatMap { [weak self, recruitmentPostUseCase] request in
                
                self?.currentPostVO.accept([])
                self?.nextPagingRequest = .initial
                
                return recruitmentPostUseCase
                    .getPostListForWorker(
                        request: .initial,
                        postCount: 10
                    )
            }
        
        
        let pagingRequest = requestNextPage
            .compactMap { [weak self] _ in
                // 요청이 없는 경우 요청을 보내지 않는다.
                // ThirdPatry에서도 불러올 데이터가 없는 경우입니다.
                self?.nextPagingRequest
            }
            .flatMap { [recruitmentPostUseCase] request in
                recruitmentPostUseCase
                    .getPostListForWorker(
                        request: request,
                        postCount: 10
                    )
            }
            
        let postPageReqeustResult = Observable
            .merge(initialRequest, pagingRequest)
            .share()
        
        let requestPostListSuccess = postPageReqeustResult.compactMap { $0.value }
        let requestPostListFailure = postPageReqeustResult.compactMap { $0.error }
        
        postBoardData = Observable
            .zip(
                currentPostVO,
                requestPostListSuccess
            )
            .compactMap { [weak self] (prevPostList, fetchedData) -> [WorkerEmployCardViewModelable]? in
                
                guard let self else { return nil }
                
                // 다음 요청설정
                var nextRequest: PostPagingRequestForWorker?
                if let prevRequest = self.nextPagingRequest {
                    
                    if let nextPageId = fetchedData.nextPageId {
                        // 다음값이 있는 경우
                        switch prevRequest {
                        case .initial:
                            nextRequest = .paging(source: .native, nextPageId: nextPageId)
                        case .paging(let source, let nextPageId):
                            nextRequest = .paging(source: .thirdParty, nextPageId: nextPageId)
                        }
                    } else {
                        // 다음값이 없는 경우
                        switch prevRequest {
                        case .initial:
                            // 써드파티 데이터 호출
                            nextRequest = .paging(source: .thirdParty, nextPageId: nil)
                        case .paging(let source, _):
                            switch source {
                            case .native:
                                // 써드파티 데이터 호출
                                nextRequest = .paging(source: .thirdParty, nextPageId: nil)
                            case .thirdParty:
                                // 페이징 종료
                                nextRequest = nil
                            }
                        }
                    }
                }
                self.nextPagingRequest = nextRequest
                
                // 화면에 표시할 전체리스트 도출
                let fetchedPosts = fetchedData.posts
                var mergedPosts = currentPostVO.value
                mergedPosts.append(contentsOf: fetchedPosts)
                
                // 최근값 업데이트
                self.currentPostVO.accept(mergedPosts)
                
                // ViewModel 생성
                let viewModels = mergedPosts.map { postVO in
                    
                    let cardVO: WorkerNativeEmployCardVO = .create(vo: postVO)
                    let cardViewModel: OngoindWorkerEmployCardVM = .init(
                        postId: postVO.postId,
                        vo: cardVO,
                        coordinator: self.coordinator
                    )
                    
                    return cardViewModel
                }
                
                return viewModels
            }
            .asDriver(onErrorJustReturn: [])
        
        alert = requestPostListFailure
            .map { error in
                return DefaultAlertContentVO(
                    title: "시스템 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    /// Test
    func fetchWorkerLocation() -> String {
        "서울시 영등포구"
    }
}

