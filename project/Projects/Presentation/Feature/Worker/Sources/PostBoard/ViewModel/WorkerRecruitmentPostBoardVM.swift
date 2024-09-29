//
//  WorkerRecruitmentPostBoardVM.swift
//  WorkerFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit
import Core


import RxCocoa
import RxSwift

public typealias BoardRefreshResult = (isRefreshed: Bool, postData: [RecruitmentPostForWorkerRepresentable])

/// 페이징 보드
public protocol WorkerPagablePostBoardVMable: BaseViewModel, AppliableWorkerEmployCardVMable {
    
    var coordinator: WorkerRecruitmentBoardCoordinatable? { get }
    
    var recruitmentPostUseCase: RecruitmentPostUseCase { get }
    
    /// 다음 페이지를 요청합니다.
    var requestNextPage: PublishRelay<Void> { get }
    
    /// 화면이 등장할 때마다 리스트를 초기화합니다.
    var requestInitialPageRequest: PublishRelay<Void> { get }
    
    /// 페이지요청에 대한 결과를 전달합니다.
    var postBoardData: Driver<BoardRefreshResult>? { get }
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
    
    /// 프로필 수정버튼이 눌린 경우
    var editProfileButtonClicked: PublishRelay<Void> { get }
    
    /// 요양보호사 위치 정보를 전달합니다.
    var workerLocationTitleText: Driver<String>? { get }
}

public class WorkerRecruitmentPostBoardVM: BaseViewModel, WorkerRecruitmentPostBoardVMable {
    
    @Injected public var recruitmentPostUseCase: RecruitmentPostUseCase
    @Injected var workerProfileUseCase: WorkerProfileUseCase
    
    // Init
    public weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    
    // Output
    public var postBoardData: Driver<(isRefreshed: Bool, postData: [RecruitmentPostForWorkerRepresentable])>?
    public var workerLocationTitleText: Driver<String>?
    public var idleAlertVM: RxCocoa.Driver<any DSKit.IdleAlertViewModelable>?
    
    
    // Input
    public var editProfileButtonClicked: PublishRelay<Void> = .init()
    public var requestInitialPageRequest: PublishRelay<Void> = .init()
    public var requestWorkerLocation: PublishRelay<Void> = .init()
    public var requestNextPage: PublishRelay<Void> = .init()
    public var applyButtonClicked: PublishRelay<(postId: String, postTitle: String)> = .init()
    
    // Paging
    /// 값이 nil이라면 요청을 보내지 않습니다.
    var nextPagingRequest: PostPagingRequestForWorker? = .initial
    /// 가장최신의 데이터를 홀드, 다음 요청시 해당데이터에 새로운 데이터를 더해서 방출
    private let currentPostVO: BehaviorRelay<[RecruitmentPostForWorkerRepresentable]> = .init(value: [])
    
    // Observable
    let dispostBag = DisposeBag()
    
    public init(coordinator: WorkerRecruitmentBoardCoordinatable) {
        self.coordinator = coordinator
        
        super.init()
        
        // MARK: 상단 위치정보 불러오기
        workerLocationTitleText = requestWorkerLocation
            .flatMap { [workerProfileUseCase] _ in
                workerProfileUseCase.getProfile(mode: .myProfile)
            }
            .map { [weak self] result in
                switch result {
                case .success(let profileVO):
                    let address = profileVO.address.roadAddress
                    let locationText = self?.convertStringToLessThan3Words(target: address)
                    return locationText ?? "케어밋"
                case .failure(let error):
                    printIfDebug("프로필 불러오기 실패", error.message)
                    return "케어밋"
                }
            }
            .asDriver(onErrorJustReturn: "케어밋")
        
        // MARK: 지원하기
        let applyRequest: PublishRelay<String> = .init()
        self.idleAlertVM = applyButtonClicked
            .map { (postId: String, postTitle: String) in
                DefaultIdleAlertVM(
                    title: "'\(postTitle)'\n공고에 지원하시겠어요?",
                    description: "",
                    acceptButtonLabelText: "지원하기",
                    cancelButtonLabelText: "취소하기",
                    onAccepted: { [applyRequest] in
                        applyRequest.accept(postId)
                    }
                )
            }
            .asDriver(onErrorDriveWith: .never())
        
        let applyRequestResult = mapEndLoading(mapStartLoading(applyRequest.asObservable())
            .flatMap { [recruitmentPostUseCase] postId in
                
                // 리스트화면에서는 앱내 지원만 지원합니다.
                return recruitmentPostUseCase
                    .applyToPost(postId: postId, method: .app)
            })
            .share()
        
        
        let applyRequestSuccess = applyRequestResult.compactMap { $0.value }.share()
        
        // 스낵바
        applyRequestSuccess
            .subscribe { [weak self] _ in
                
                self?.snackBar.onNext(
                    .init(titleText: "지원이 완료되었어요.")
                )
            }
            .disposed(by: dispostBag)
        
        // 지원하기 성공시 새로고침
        applyRequestSuccess
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
        let initialRequest = mapEndLoading(mapStartLoading(requestInitialPageRequest.asObservable())
            .flatMap { [weak self, recruitmentPostUseCase] request in
                
                self?.currentPostVO.accept([])
                self?.nextPagingRequest = .initial
                
                return recruitmentPostUseCase
                    .getPostListForWorker(
                        request: .initial,
                        postCount: 10
                    )
            })
            .share()
        
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
            .compactMap { [weak self] (prevPostList, fetchedData) -> BoardRefreshResult? in
                
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
                
                return (isRefreshed, mergedPosts)
            }
            .asDriver(onErrorDriveWith: .never())
        
        let requestPostListFailureAlert = requestPostListFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "공고 불러오기 오류",
                    message: error.message
                )
            }
        
        // MARK: 프로필 수정
        editProfileButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.showWorkerProfile()
            })
            .disposed(by: dispostBag)
        
        Observable
            .merge(
                applyRequestFailureAlert,
                requestPostListFailureAlert
            )
            .subscribe(self.alert)
            .disposed(by: dispostBag)
    }
    
    func convertStringToLessThan3Words(target: String) -> String {
        let splited = target.split(separator: " ")
        var resultParts: [String] = []
        for (index, part) in splited.enumerated() {
            
            if index >= 3 { break }
            
            let current = String(part)
            resultParts.append(current)
        }
        return resultParts.joined(separator: " ")
    }
}

// MARK: WorkerPagablePostBoardVMable + Extension
extension WorkerPagablePostBoardVMable {
    
    public func showPostDetail(postType: RecruitmentPostType, id: String) {
        coordinator?.showPostDetail(postInfo: .init(
            type: postType,
            id: id
        ))
    }
    
    public func setPostFavoriteState(isFavoriteRequest: Bool, postId: String, postType: RecruitmentPostType) -> RxSwift.Single<Bool> {
        
        return Single<Bool>.create { [weak self] observer in
            
            guard let self else { return Disposables.create { } }
            
            let observable: Single<Result<Void, DomainError>>!
            
            // 로딩화면 시작
            self.showLoading.onNext(())
            
            if isFavoriteRequest {
                
                observable = recruitmentPostUseCase
                    .addFavoritePost(
                        postId: postId,
                        type: postType
                    )
                
            } else {
                
                observable = recruitmentPostUseCase
                    .removeFavoritePost(postId: postId)
            }
            
            let reuslt = observable
                .asObservable()
                .map({ [weak self] result in
                    
                    // 로딩화면 종료
                    self?.dismissLoading.onNext(())
                    return result
                })
                .share()
            
            let success = reuslt.compactMap { $0.value }
            let failure = reuslt.compactMap { $0.error }
            
            let failureAlertDisposable = failure
                .subscribe(onNext: { [weak self] error in
                    let vo = DefaultAlertContentVO(
                        title: "즐겨찾기 오류",
                        message: error.message
                    )
                    
                    self?.alert.onNext(vo)
                })
                
            
            let disposable = Observable
                .merge(
                    success.map { _ in true }.asObservable(),
                    failure.map { _ in false }.asObservable()
                )
                .asSingle()
                .subscribe(observer)
            
            return Disposables.create {
                disposable.dispose()
                failureAlertDisposable.dispose()
            }
        }
    }
}
