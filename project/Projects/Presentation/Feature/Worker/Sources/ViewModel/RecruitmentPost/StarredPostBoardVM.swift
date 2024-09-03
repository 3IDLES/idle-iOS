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

public class StarredPostBoardVM: WorkerPagablePostBoardVMable {
    
    // Input
    public var viewDidLoad: RxRelay.PublishRelay<Void> = .init()
    public var requestNextPage: RxRelay.PublishRelay<Void> = .init()
    
    // Output
    public var postBoardData: RxCocoa.Driver<[any DSKit.WorkerEmployCardViewModelable]>?
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
                viewDidLoad.asObservable(),
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
            .compactMap { [weak self] (prevPostList, fetchedData) -> [WorkerEmployCardViewModelable]? in
                
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
                
                // ViewModel 생성
                let viewModels = mergedPosts.map { vo in
                    
                    let cardVO: WorkerNativeEmployCardVO = .create(vo: vo)
                    
                    let vm: OngoindWorkerEmployCardVM = .init(
                        postId: vo.postId,
                        vo: cardVO,
                        coordinator: self.coordinator
                    )
                    
                    return vm
                }
                
                return viewModels
            }
            .asDriver(onErrorJustReturn: [])
        
        alert = requestPostListFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "즐겨찾기한 공고 불러오기 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    
    func publishStarredPostMocks() -> Single<Result<[NativeRecruitmentPostForWorkerVO], DomainError>> {
        return .just(.success((0..<10).map { _ in .mock }))
    }
}

class StarredWorkerEmployCardVM: WorkerEmployCardViewModelable {
    
    
    
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    
    // Init
    let postId: String
    var cellViewObject: Entity.WorkerNativeEmployCardVO
    
    public var cardClicked: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var starButtonClicked: RxRelay.PublishRelay<Bool> = .init()
    
    let disposeBag = DisposeBag()
    
    public init
        (
            postId: String,
            vo: WorkerNativeEmployCardVO,
            coordinator: WorkerRecruitmentBoardCoordinatable? = nil
        )
    {
        self.postId = postId
        self.cellViewObject = vo
        self.coordinator = coordinator
        
        // MARK: 버튼 처리
        applyButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                // 지원하기 버튼 눌림
            })
            .disposed(by: disposeBag)
        
        cardClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.coordinator?.showPostDetail(
                    postId: postId
                )
            })
            .disposed(by: disposeBag)
        
        starButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                // 즐겨찾기 버튼눌림
            })
            .disposed(by: disposeBag)
    }
}
