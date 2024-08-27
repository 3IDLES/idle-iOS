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


public class CenterRecruitmentPostBoardVM: CenterRecruitmentPostBoardViewModelable {
    
    // Init
    weak var coordinator: CenterRecruitmentPostBoardScreenCoordinator?
    let recruitmentPostUseCase: RecruitmentPostUseCase

    public var requestOngoingPost: PublishRelay<Void> = .init()
    public var requestClosedPost: PublishRelay<Void> = .init()
    
    public var ongoingPostInfo: RxCocoa.Driver<[Entity.RecruitmentPostInfoForCenterVO]>?
    public var closedPostInfo: RxCocoa.Driver<[Entity.RecruitmentPostInfoForCenterVO]>?
    
    public var alert: Driver<DefaultAlertContentVO>?
    
    public init(coordinator: CenterRecruitmentPostBoardScreenCoordinator?, recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
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
        
        alert = Observable.merge(
            requestOngoingPostFailure,
            requestClosedPostFailure
        ).map { error in
            DefaultAlertContentVO(
                title: "시스템 오류",
                message: error.message
            )
        }
        .asDriver(onErrorJustReturn: .default)
    }
    
    public func createCellVM(postInfo: Entity.RecruitmentPostInfoForCenterVO) -> any DSKit.CenterEmployCardViewModelable {
        CenterEmployCardVM(
            postInfo: postInfo,
            coordinator: coordinator,
            recruitmentPostUseCase: recruitmentPostUseCase
        )
    }
}

// MARK: 카드 뷰에 사용될 ViewModel
class CenterEmployCardVM: CenterEmployCardViewModelable {
    
    // Init
    let postInfo: RecruitmentPostInfoForCenterVO
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
    
    init(postInfo: RecruitmentPostInfoForCenterVO, coordinator: CenterRecruitmentPostBoardScreenCoordinator?, recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.postInfo = postInfo
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
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.coordinator?.showPostDetailScreenForCenter(postId: postInfo.id)
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
    }
}
