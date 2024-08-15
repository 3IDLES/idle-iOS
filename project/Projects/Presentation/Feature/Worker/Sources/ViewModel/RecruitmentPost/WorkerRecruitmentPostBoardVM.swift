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

public protocol WorkerRecruitmentPostBoardVMable: DefaultAlertOutputable {
    
    var ongoingPostCardVO: Driver<[WorkerEmployCardVO]>? { get }
    var viewWillAppear: PublishRelay<Void> { get }
    var locationTtitleText: PublishRelay<String> { get }
    
    func createCellVM(postId: String, vo: WorkerEmployCardVO) -> WorkerEmployCardViewModelable
}


public class WorkerRecruitmentPostBoardVM: WorkerRecruitmentPostBoardVMable {
    
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    
    public var ongoingPostCardVO: RxCocoa.Driver<[Entity.WorkerEmployCardVO]>?
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    public var viewWillAppear: RxRelay.PublishRelay<Void> = .init()
    public var locationTtitleText: RxRelay.PublishRelay<String> = .init()
    
    public init(coordinator: WorkerRecruitmentBoardCoordinatable) {
        
        self.coordinator = coordinator
        
        let requestOngoingPostResult = viewWillAppear
            .flatMap { [unowned self] _ in
                publishOngoingPostMocks()
            }
            .share()
        
        let requestOngoingPostSuccess = requestOngoingPostResult.compactMap { $0.value }
        let requestOngoingPostFailure = requestOngoingPostResult.compactMap { $0.error }
        
        ongoingPostCardVO = requestOngoingPostSuccess.asDriver(onErrorJustReturn: [])
        
        alert = requestOngoingPostFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "시스템 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    public func createCellVM(postId: String, vo: Entity.WorkerEmployCardVO) -> any DSKit.WorkerEmployCardViewModelable {
        WorkerEmployCardVM(
            postId: postId,
            vo: vo,
            coordinator: coordinator
        )
    }
    
    func publishOngoingPostMocks() -> Single<Result<[WorkerEmployCardVO], RecruitmentPostError>> {
        return .just(.success((0...10).map { _ in WorkerEmployCardVO.mock }))
    }
}

public class WorkerEmployCardVM: WorkerEmployCardViewModelable {
    
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    
    // Init
    let postId: String
    
    public var renderObject: RxCocoa.Driver<DSKit.WorkerEmployCardRO>?
    public var applicationInformation: RxCocoa.Driver<DSKit.ApplicationInfo>?
    
    public var cardClicked: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<Void> = .init()
    public var starButtonClicked: RxRelay.PublishRelay<Bool> = .init()
    
    let disposeBag = DisposeBag()
    
    public init
        (
            postId: String,
            vo: WorkerEmployCardVO,
            coordinator: WorkerRecruitmentBoardCoordinatable? = nil
        )
    {
        self.postId = postId
        self.coordinator = coordinator
        
        // MARK: 지원여부
        let applicationInformation: BehaviorRelay<ApplicationInfo> = .init(value: .mock)
        self.applicationInformation = applicationInformation.asDriver()
        
        // MARK: Card RenderObject
        let workerEmployCardRO: BehaviorRelay<WorkerEmployCardRO> = .init(value: .mock)
        renderObject = workerEmployCardRO.asDriver(onErrorJustReturn: .mock)
        
        workerEmployCardRO.accept(WorkerEmployCardRO.create(vo: vo))
        
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
                
                coordinator?.showPostDetail(
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
