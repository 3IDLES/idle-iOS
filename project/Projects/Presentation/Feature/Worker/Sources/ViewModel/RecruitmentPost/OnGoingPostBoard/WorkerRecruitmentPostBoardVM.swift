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

public struct PostBoardCellData {
    let postId: String
    let cardVO: WorkerNativeEmployCardVO
}

/// 페이징 보드
public protocol WorkerPagablePostBoardVMable: DefaultAlertOutputable & WorkerNativeEmployCardViewModelable {
    /// 다음 페이지를 요청합니다.
    var requestNextPage: PublishRelay<Void> { get }
    
    /// 화면이 등장할 때마다 리스트를 초기화합니다.
    var requestInitialPageRequest: PublishRelay<Void> { get }
    
    /// 페이지요청에 대한 결과를 전달합니다.
    var postBoardData: Driver<(isRefreshed: Bool, cellData: [PostBoardCellData])>? { get }
}

/// 페이징 + 지원하기
public protocol WorkerAppliablePostBoardVMable: WorkerPagablePostBoardVMable {
    /// 지원하기 Alert
    var idleAlertVM: Driver<IdleAlertViewModelable>? { get }
}

/// 페이징 + 지원하기 + 요양보호사 위치정보
public protocol WorkerRecruitmentPostBoardVMable: WorkerAppliablePostBoardVMable {
    
    /// 요양보호사 위치정보를 요청합니다.
    var requestWorkerLocation: PublishRelay<Void> { get }
    
    /// 요양보호사 위치 정보를 전달합니다.
    var workerLocationTitleText: Driver<String>? { get }
}

public class WorkerRecruitmentPostBoardVM: WorkerRecruitmentPostBoardVMable {
    
    // Output
    public var postBoardData: Driver<(isRefreshed: Bool, cellData: [PostBoardCellData])>?
    public var workerLocationTitleText: Driver<String>?
    public var idleAlertVM: RxCocoa.Driver<any DSKit.IdleAlertViewModelable>?
    public var alert: Driver<DefaultAlertContentVO>?
    
    // Input
    public var requestInitialPageRequest: PublishRelay<Void> = .init()
    public var requestWorkerLocation: PublishRelay<Void> = .init()
    public var requestNextPage: PublishRelay<Void> = .init()
    public var applyButtonClicked: PublishRelay<(postId: String, postTitle: String)> = .init()
    
    
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
        
        // MARK: 상단 위치정보 불러오기
        workerLocationTitleText = requestWorkerLocation
            .compactMap { [weak self] _ in
                self?.fetchWorkerLocation()
            }
            .asDriver(onErrorJustReturn: "위치정보확인불가")
        
        // MARK: 지원하기
        let applyRequest: PublishRelay<String> = .init()
        self.idleAlertVM = applyButtonClicked
            .map { (postId: String, postTitle: String) in
                DefaultIdleAlertVM(
                    title: "'\(postTitle)'\n공고에 지원하시겠어요?",
                    description: "",
                    acceptButtonLabelText: "지원하기",
                    cancelButtonLabelText: "취소하기") { [applyRequest] in
                        applyRequest.accept(postId)
                    }
            }
            .asDriver(onErrorDriveWith: .never())
            
        let applyRequestResult = applyRequest
            .flatMap { [recruitmentPostUseCase] postId in
                // 리스트화면에서는 앱내 지원만 지원합니다.
                recruitmentPostUseCase
                    .applyToPost(postId: postId, method: .app)
            }
            .share()
        
        // 지원하기 성공시 새로고침
        applyRequestResult
            .compactMap { $0.value }
            .bind(to: requestInitialPageRequest)
            .disposed(by: dispostBag)
        
        let applyRequestFailure = applyRequestResult.compactMap { $0.error }
        
        let applyRequestFailureAlert = applyRequestFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "지원하기 실패",
                    message: error.message
                )
            }

        
        // MARK: 공고리스트 처음부터 요청하기
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
        
        // MARK: 공고리스트 페이징 요청
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
            .compactMap { [weak self] (prevPostList, fetchedData) -> (Bool, [PostBoardCellData])? in
                
                guard let self else { return nil }
                
                let isRefreshed: Bool = self.nextPagingRequest == .initial
                
                // 다음 요청설정
                var nextRequest: PostPagingRequestForWorker?
                if let prevRequest = self.nextPagingRequest {
                    
                    if let nextPageId = fetchedData.nextPageId {
                        // 다음값이 있는 경우
                        switch prevRequest {
                        case .initial:
                            nextRequest = .paging(source: .native, nextPageId: nextPageId)
                        case .paging(let source, let nextPageId):
                            nextRequest = .paging(source: source, nextPageId: nextPageId)
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
                
                // cellData생성
                let cellData: [PostBoardCellData] = mergedPosts.map { postVO in
                    
                    let cardVO: WorkerNativeEmployCardVO = .create(vo: postVO)
                    return .init(postId: postVO.postId, cardVO: cardVO)
                }
                
                return (isRefreshed, cellData)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let requestPostListFailureAlert = requestPostListFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "공고 불러오기 오류",
                    message: error.message
                )
            }
        
        self.alert = Observable
            .merge(
                applyRequestFailureAlert,
                requestPostListFailureAlert
            )
            .asDriver(onErrorJustReturn: .default)
    }
    
    public func showPostDetail(id: String) {
        coordinator?.showPostDetail(postId: id)
    }
    
    /// Test
    func fetchWorkerLocation() -> String {
        "서울시 영등포구"
    }
}
