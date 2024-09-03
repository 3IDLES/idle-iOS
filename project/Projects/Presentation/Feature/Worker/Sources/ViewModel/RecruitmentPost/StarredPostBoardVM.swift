//
//  StarredPostBoardVM.swift
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

public class StarredPostBoardVM: WorkerAppliablePostBoardVMable {
    
    // Input
    public var requestInitialPageRequest: RxRelay.PublishRelay<Void> = .init()
    public var requestNextPage: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<(postId: String, postTitle: String)> = .init()
    
    // Output
    public var postBoardData: Driver<[PostBoardCellData]>?
    public var alert: Driver<Entity.DefaultAlertContentVO>?
    public var idleAlertVM: RxCocoa.Driver<any DSKit.IdleAlertViewModelable>?
    
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
                    .getFavoritePostListForWorker(
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
            .compactMap { [weak self] (prevPostList, fetchedData) -> [PostBoardCellData]? in
                
                guard let self else { return nil }
                
                // TODO: ‼️ ‼️ 즐겨찾기 공고의 경우 서버에서 아직 워크넷 공고를 처리하는 방법을 정하지 못했음으로 추후에 수정할 예정입니다.
                
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
                
                return cellData
            }
            .asDriver(onErrorJustReturn: [])
        
        // MARK: 지원하기
        let applyRequest: PublishRelay<String> = .init()
        self.idleAlertVM = applyButtonClicked
            .map { (postId: String, postTitle: String) in
                DefaultIdleAlertVM(
                    title: "'postTitle'\n공고에 지원하시겠어요?",
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
        
        let applyRequestFailure = applyRequestResult.compactMap { $0.error }
        
        let applyRequestFailureAlert = applyRequestFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "지원하기 실패",
                    message: error.message
                )
            }
        
        let requestPostListFailureAlert = requestPostListFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "즐겨찾기한 공고 불러오기 오류",
                    message: error.message
                )
            }
        
        alert = Observable
            .merge(applyRequestFailureAlert, requestPostListFailureAlert)
            .asDriver(onErrorJustReturn: .default)
    }
    
    public func showPostDetail(id: String) {
        coordinator?.showCenterProfile(centerId: id)
    }
}
