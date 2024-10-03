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
import Domain
import DSKit
import Core


import RxCocoa
import RxSwift

protocol CenterRecruitmentPostBoardViewModelable: OnGoingPostViewModelable & ClosedPostViewModelable {
}


class PostBoardPageViewModel: BaseViewModel, CenterRecruitmentPostBoardViewModelable {
    
    // Injected
    @Injected var recruitmentPostUseCase: RecruitmentPostUseCase
    
    // Navigation
    var presentRegisterPostPage: (() -> ())?
    var createPostCellViewModel: ((RecruitmentPostInfoForCenterVO, PostState) -> CenterEmployCardViewModelable)!

    var requestOngoingPost: PublishRelay<Void> = .init()
    var requestClosedPost: PublishRelay<Void> = .init()
    var registerPostButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    var ongoingPostInfo: RxCocoa.Driver<[RecruitmentPostInfoForCenterVO]>?
    var closedPostInfo: RxCocoa.Driver<[RecruitmentPostInfoForCenterVO]>?
    var showRemovePostAlert: RxCocoa.Driver<any DSKit.IdleAlertViewModelable>?
    
    public override init() {
        
        super.init()
        
        let requestOngoingPostResult = requestOngoingPost
            .flatMap { [weak self, recruitmentPostUseCase] _ in
                
                // 로딩 시작
                self?.showLoading.onNext(())
                
                return recruitmentPostUseCase
                    .getOngoingPosts()
            }
            .share()
        
        requestOngoingPostResult
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe (onNext: { [weak self] _ in
                self?.dismissLoading
                    .onNext(())
            })
            .disposed(by: disposeBag)
        
        let requestOngoingPostSuccess = requestOngoingPostResult.compactMap { $0.value }
        let requestOngoingPostFailure = requestOngoingPostResult.compactMap { $0.error }
        
        ongoingPostInfo = requestOngoingPostSuccess
            .asDriver(onErrorJustReturn: [])
            
        
        let requestClosedPostResult = requestClosedPost
            .flatMap { [weak self, recruitmentPostUseCase] _ in
                
                // 로딩 시작
                self?.showLoading.onNext(())
                
                return recruitmentPostUseCase
                    .getClosedPosts()
            }
            .share()
        
        requestClosedPostResult
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe (onNext: { [weak self] _ in
                self?.dismissLoading
                    .onNext(())
            })
            .disposed(by: disposeBag)
        
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
                    cancelButtonLabelText: "취소하기",
                    onAccepted: { [closePostConfirmed] in
                        closePostConfirmed.accept(postId)
                    }
                )
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
            .map({ [weak self] value in
                // 스낵바
                self?.snackBar.onNext(.init(titleText: "채용을 종료했어요."))
                
                return value
            })
            .bind(to: requestOngoingPost)
            .disposed(by: disposeBag)
        
        let closePostFailure = closePostResult.compactMap { $0.error }
        
        // 공고등록버튼
        registerPostButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentRegisterPostPage?()
            })
            .disposed(by: disposeBag)
        
        Observable.merge(
            requestOngoingPostFailure,
            requestClosedPostFailure,
            closePostFailure
        ).map { error in
            DefaultAlertContentVO(
                title: "메인화면 오류",
                message: error.message
            )
        }
        .subscribe(onNext: { [weak self] alertVO in
            guard let self else { return }
            
            alert.onNext(alertVO)
        })
        .disposed(by: disposeBag)
    }
}

// MARK: 카드 뷰에 사용될 ViewModel
class CenterEmployCardVM: CenterEmployCardViewModelable {
    
    @Injected var recruitmentPostUseCase: RecruitmentPostUseCase
    
    // Navigation
    var presentPostDetailPage: ((String, PostState) -> ())?
    var presentPostApplicantPage: ((String) -> ())?
    var presentPostEditPage: ((String) -> ())?
    
    // Init
    let postInfo: RecruitmentPostInfoForCenterVO
    let postState: PostState
    
    // Output
    let renderObject: CenterEmployCardRO
    var applicantCountText: Driver<String>?
    
    // Input
    var cardClicked: PublishRelay<Void> = .init()
    var checkApplicantBtnClicked: PublishRelay<Void> = .init()
    var editPostBtnClicked: PublishRelay<Void> = .init()
    var terminatePostBtnClicked: PublishRelay<Void> = .init()
    
    let disposeBag = DisposeBag()
    
    init(postInfo: RecruitmentPostInfoForCenterVO, postState: PostState) {
        self.postInfo = postInfo
        self.postState = postState
        
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
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                let info = obj.postInfo
                obj.presentPostDetailPage?(info.id, postState)
            })
            .disposed(by: disposeBag)
        
        
        if postInfo.state == .closed { return }
        // 이전 공고인 경우 버튼 바인딩 하지 않음
        
        checkApplicantBtnClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                let info = obj.postInfo
                obj.presentPostApplicantPage?(info.id)
            })
            .disposed(by: disposeBag)
        
        
        editPostBtnClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                let info = obj.postInfo
                obj.presentPostEditPage?(info.id)
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
