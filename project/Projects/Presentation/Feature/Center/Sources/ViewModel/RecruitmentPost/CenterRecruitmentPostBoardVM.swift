//
//  CenterRecruitmentPostBoardVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/13/24.
//

import Foundation
import UIKit
import BaseFeature
import PresentationCore
import UseCaseInterface
import RxCocoa
import RxSwift
import Entity
import DSKit

public protocol CenterRecruitmentPostBoardViewModelable: OnGoingPostViewModelable & ClosedPostViewModelable {
    var alert: Driver<DefaultAlertContentVO>? { get }
}


public class CenterRecruitmentPostBoardVM: BaseViewModel, CenterRecruitmentPostBoardViewModelable {
    
    // Init
    weak var coordinator: CenterRecruitmentPostBoardScreenCoordinator?
    let recruitmentPostUseCase: RecruitmentPostUseCase

    public var requestOngoingPost: PublishRelay<Void> = .init()
    public var requestClosedPost: PublishRelay<Void> = .init()
    public var registerPostButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    public var ongoingPostInfo: RxCocoa.Driver<[Entity.RecruitmentPostInfoForCenterVO]>?
    public var closedPostInfo: RxCocoa.Driver<[Entity.RecruitmentPostInfoForCenterVO]>?
    public var showRemovePostAlert: RxCocoa.Driver<any DSKit.IdleAlertViewModelable>?
    
    let disposeBag = DisposeBag()
    
    public init(coordinator: CenterRecruitmentPostBoardScreenCoordinator?, recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        super.init()
        
        let requestOngoingPostResult = requestOngoingPost
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getOngoingPosts()
            }
            .share()
        
        let requestOngoingPostSuccess = requestOngoingPostResult.compactMap { $0.value }
        let requestOngoingPostFailure = requestOngoingPostResult.compactMap { $0.error }
        
        ongoingPostInfo = requestOngoingPostSuccess
            .asDriver(onErrorJustReturn: [])
            
        
        let requestClosedPostResult = requestClosedPost
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getClosedPosts()
            }
            .share()
        
        let requestClosedPostSuccess = requestClosedPostResult.compactMap { $0.value }
        let requestClosedPostFailure = requestClosedPostResult.compactMap { $0.error }
        
        closedPostInfo = requestClosedPostSuccess
            .asDriver(onErrorJustReturn: [])
        
        // MARK: Show
        let closePostConfirmed: PublishRelay<String> = .init()
        showRemovePostAlert = NotificationCenter.default.rx
            .notification(.removePostRequestFromCell)
            .map({ notification in
                let object = notification.object as! [String: Any]
                let postId = object["postId"] as! String
                return postId
            })
            .map({ (postId: String) in
                
                let vm = DefaultIdleAlertVM(
                    title: "채용을 종료하시겠어요?",
                    description: "채용 종료 시 지원자 정보는 초기화됩니다.",
                    acceptButtonLabelText: "종료하기",
                    cancelButtonLabelText: "취소하기"
                ) { [closePostConfirmed] in
                    closePostConfirmed.accept(postId)
                }
                return vm
            })
            .asDriver(onErrorDriveWith: .never())
        
        // 채용종료 버튼
        let closePostResult = closePostConfirmed
            .flatMap { [recruitmentPostUseCase] postId in
                recruitmentPostUseCase.closePost(id: postId)
            }
            .share()
        
        let closePostSuccess = closePostResult.compactMap { $0.value }
        
        // 새로고침
        closePostSuccess
            .bind(to: requestOngoingPost)
            .disposed(by: disposeBag)
        
        let closePostFailure = closePostResult.compactMap { $0.error }
        
        // 공고등록버튼
        registerPostButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showRegisterPostScreen()
            })
            .disposed(by: disposeBag)
        
        alert = Observable.merge(
            requestOngoingPostFailure,
            requestClosedPostFailure,
            closePostFailure
        ).map { error in
            DefaultAlertContentVO(
                title: "메인화면 오류",
                message: error.message
            )
        }
        .asDriver(onErrorJustReturn: .default)
    }
    
    public func createOngoingPostCellVM(postInfo: Entity.RecruitmentPostInfoForCenterVO) -> any DSKit.CenterEmployCardViewModelable {
        CenterEmployCardVM(
            postInfo: postInfo,
            postState: .onGoing,
            coordinator: coordinator,
            recruitmentPostUseCase: recruitmentPostUseCase
        )
    }
    
    public func createClosedPostCellVM(postInfo: Entity.RecruitmentPostInfoForCenterVO) -> any DSKit.CenterEmployCardViewModelable {
        CenterEmployCardVM(
            postInfo: postInfo,
            postState: .closed,
            coordinator: coordinator,
            recruitmentPostUseCase: recruitmentPostUseCase
        )
    }
}

// MARK: 카드 뷰에 사용될 ViewModel
class CenterEmployCardVM: CenterEmployCardViewModelable {
    
    // Init
    let postInfo: RecruitmentPostInfoForCenterVO
    let postState: PostState
    let recruitmentPostUseCase: RecruitmentPostUseCase
    weak var coordinator: CenterRecruitmentPostBoardScreenCoordinator?
    
    // Output
    let renderObject: CenterEmployCardRO
    var applicantCountText: Driver<String>?
    
    // Input
    var cardClicked: PublishRelay<Void> = .init()
    var checkApplicantBtnClicked: PublishRelay<Void> = .init()
    var editPostBtnClicked: PublishRelay<Void> = .init()
    var terminatePostBtnClicked: PublishRelay<Void> = .init()
    
    let disposeBag = DisposeBag()
    
    init(postInfo: RecruitmentPostInfoForCenterVO, postState: PostState, coordinator: CenterRecruitmentPostBoardScreenCoordinator?, recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.postInfo = postInfo
        self.postState = postState
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        // MARK: RenderObject
        self.renderObject = CenterEmployCardRO.create(vo: postInfo)
        
        // MARK: 지원자 수 조회
        let getApplicantCountResult = recruitmentPostUseCase
            .getPostApplicantCount(id: postInfo.id)
            .asObservable()
            .share()
        
        let getApplicantCountSuccess = getApplicantCountResult.compactMap { $0.value }
        let getApplicantCountFailure = getApplicantCountResult.compactMap { $0.error }
        
        applicantCountText = Observable
            .merge(
                getApplicantCountSuccess.map { cnt in "지원자 \(cnt)명 조회" }.asObservable(),
                getApplicantCountFailure.map { error in
                    printIfDebug("지원자수를 가져올 수 없음 \(error.message)")
                    return "지원자 수 조회 실패"
                }.asObservable()
            )
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: 버튼 처리
        cardClicked
            .subscribe(onNext: {
                [weak self] _ in
                guard let self else { return }
                
                self.coordinator?.showPostDetailScreenForCenter(postId: postInfo.id, postState: postState)
            })
            .disposed(by: disposeBag)
        
        
        if postInfo.state == .closed { return }
        // 이전 공고인 경우 버튼 바인딩 하지 않음
        
        checkApplicantBtnClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.coordinator?.showCheckingApplicantScreen(postId: postInfo.id)
            })
            .disposed(by: disposeBag)
        
        
        editPostBtnClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.coordinator?.showEditScreen(postId: postInfo.id)
            })
            .disposed(by: disposeBag)
        
        
        terminatePostBtnClicked
            .subscribe(onNext: { _ in

                NotificationCenter.default.post(
                    name: .removePostRequestFromCell,
                    object: [
                        "postId": postInfo.id
                    ]
                )
            })
            .disposed(by: disposeBag)
    }
}
