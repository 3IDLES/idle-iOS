//
//  asd.swift
//  BaseFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import RxCocoa
import RxSwift
import Entity
import PresentationCore
import UseCaseInterface

public protocol PostDetailForWorkerViewModelable {
    
    // Output
    var postForWorkerBundle: Driver<RecruitmentPostForWorkerBundle>? { get }
    var locationInfo: Driver<WorkAndWorkerLocationMapRO>? { get }
    var alert: Driver<AlertWithCompletionVO>? { get }
    
    // Input
    var viewWillAppear: PublishRelay<Void> { get }
    
    var backButtonClicked: PublishRelay<Void> { get }
    var applyButtonClicked: PublishRelay<Void> { get }
    var startButtonClicked: PublishRelay<Bool> { get }
    var centerCardClicked: PublishRelay<Void> { get }
}

public class PostDetailForWorkerVM: PostDetailForWorkerViewModelable {

    public weak var coordinator: PostDetailForWorkerCoodinator?
    
    // Init
    private let postId: String
    private let recruitmentPostUseCase: RecruitmentPostUseCase
    
    
    public var postForWorkerBundle: RxCocoa.Driver<Entity.RecruitmentPostForWorkerBundle>?
    public var locationInfo: RxCocoa.Driver<WorkAndWorkerLocationMapRO>?
    
    public var alert: RxCocoa.Driver<Entity.AlertWithCompletionVO>?
    
    
    public var backButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var startButtonClicked: RxRelay.PublishRelay<Bool> = .init()
    public var centerCardClicked: RxRelay.PublishRelay<Void> = .init()
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()
    
    private let disposeBag = DisposeBag()
    
    public init(
            postId: String,
            coordinator: PostDetailForWorkerCoodinator?,
            recruitmentPostUseCase: RecruitmentPostUseCase
        )
    {
        self.postId = postId
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        let getPostDetailResult = viewWillAppear
            .flatMap { [recruitmentPostUseCase] _ in
                recruitmentPostUseCase
                    .getPostDetailForWorker(id: postId)
            }
            .share()
        
        let getPostDetailSuccess = getPostDetailResult.compactMap { $0.value }
        let getPostDetailFailure = getPostDetailResult.compactMap { $0.error }
        
        postForWorkerBundle = getPostDetailSuccess.asDriver(onErrorRecover: { _ in fatalError() })
        
        // Alert 처리 필요
        alert = getPostDetailFailure
            .map { error in
                AlertWithCompletionVO(
                    title: "공고 불러오기 실패",
                    message: error.message,
                    buttonInfo: [
                        ("닫기",  { [weak self] in
                            self?.coordinator?.coordinatorDidFinish()
                        })
                    ]
                )
            }
            .asDriver(onErrorJustReturn: .default)
        
        
        // MARK: 버튼 처리
        backButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        // 지원하기 버튼 클릭

        // 즐겨찾기 버튼 클릭
        
        // 센터 프로필 조회 버튼클릭
        centerCardClicked
            .withLatestFrom(getPostDetailSuccess)
            .subscribe(onNext: { [weak self] bundle in
                guard let self else { return }
                let centerId = bundle.centerInfo.centerId
                self.coordinator?.showCenterProfileScreen(centerId: centerId)
            })
            .disposed(by: disposeBag)
    }
}
