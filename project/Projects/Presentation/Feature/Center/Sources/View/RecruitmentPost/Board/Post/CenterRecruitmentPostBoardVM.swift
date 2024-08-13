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
import RxCocoa
import RxSwift
import Entity
import DSKit

public protocol CenterRecruitmentPostBoardViewModelable: OnGoingPostViewModelable & ClosedPostViewModelable {
    var alert: Driver<DefaultAlertContentVO>? { get }
}


public class CenterRecruitmentPostBoardVM: CenterRecruitmentPostBoardViewModelable {
    
    weak var coordinator: RecruitmentManagementCoordinatable?

    public var requestOngoingPost: PublishRelay<Void> = .init()
    public var requestClosedPost: PublishRelay<Void> = .init()
    
    public var ongoingPostCardVO: Driver<[CenterEmployCardVO]>?
    public var closedPostCardVO: Driver<[CenterEmployCardVO]>?
    
    public var alert: Driver<DefaultAlertContentVO>?
    
    public init(coordinator: RecruitmentManagementCoordinatable?) {
        self.coordinator = coordinator
        
        let requestOngoingPostResult = requestOngoingPost
            .flatMap { [unowned self] _ in
                publishOngoingPostMocks()
            }
            .share()
        
        let requestOngoingPostSuccess = requestOngoingPostResult.compactMap { $0.value }
        let requestOngoingPostFailure = requestOngoingPostResult.compactMap { $0.error }
        
        ongoingPostCardVO = requestOngoingPostSuccess.asDriver(onErrorJustReturn: [])
            
        
        let requestClosedPostResult = requestClosedPost
            .flatMap { [unowned self] _ in
                publishClosedPostMocks()
            }
            .share()
        
        let requestClosedPostSuccess = requestClosedPostResult.compactMap { $0.value }
        let requestClosedPostFailure = requestClosedPostResult.compactMap { $0.error }
        
        closedPostCardVO = requestClosedPostSuccess.asDriver(onErrorJustReturn: [])
        
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
    
    func publishOngoingPostMocks() -> Single<Result<[CenterEmployCardVO], RecruitmentPostError>> {
        return .just(.success((0...10).map { _ in CenterEmployCardVO.mock }))
    }
    
    func publishClosedPostMocks() -> Single<Result<[CenterEmployCardVO], RecruitmentPostError>> {
        return .just(.success((0...10).map { _ in CenterEmployCardVO.mock }))
    }
    
    public func createCellVM(vo: CenterEmployCardVO) -> any CenterEmployCardViewModelable {
        CenterEmployCardVM(
            vo: vo,
            coordinator: coordinator
        )
    }
}

// MARK: 카드 뷰에 사용될 ViewModel
class CenterEmployCardVM: CenterEmployCardViewModelable {
    
    weak var coordinator: RecruitmentManagementCoordinatable?
    
    // Init
    let id: String
    
    // Output
    var renderObject: Driver<CenterEmployCardRO>?
    
    // Input
    var cardClicked: PublishRelay<Void> = .init()
    var checkApplicantBtnClicked: PublishRelay<Void> = .init()
    var editPostBtnClicked: PublishRelay<Void> = .init()
    var terminatePostBtnClicked: PublishRelay<Void> = .init()
    
    let disposeBag = DisposeBag()
    
    init(vo: CenterEmployCardVO, coordinator: RecruitmentManagementCoordinatable? = nil) {
        self.id = vo.postId
        self.coordinator = coordinator
        
        // MARK: RenderObject
        let publishRelay: BehaviorRelay<CenterEmployCardRO> = .init(value: .mock)
        renderObject = publishRelay.asDriver(onErrorJustReturn: .mock)
        
        publishRelay.accept(CenterEmployCardRO.create(vo))
        
        // MARK: 버튼 처리
        checkApplicantBtnClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showCheckingApplicantScreen(vo)
            })
            .disposed(by: disposeBag)
    }
}
