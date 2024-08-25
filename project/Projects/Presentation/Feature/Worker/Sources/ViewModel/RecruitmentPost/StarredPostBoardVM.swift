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

public class StarredPostBoardVM: WorkerStaticPostBoardVMable {
    
    public var postViewWillAppear: RxRelay.PublishRelay<Void> = .init()
    
    public var postBoardData: RxCocoa.Driver<[any DSKit.WorkerEmployCardViewModelable]>?
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    // Init
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        let requestPostResult = postViewWillAppear
            .flatMap { [unowned self] _ in
                self.publishStarredPostMocks()
            }
            .share()
        
        let requestPostSuccess = requestPostResult.compactMap { $0.value }
        let requestPostFailure = requestPostResult.compactMap { $0.error }
        
        postBoardData = requestPostSuccess
            .map { postForWorkerVos in
                
                // ViewModel 생성
                let viewModels = postForWorkerVos.map { vo in
                    
                    let cardVO: WorkerEmployCardVO = .create(vo: vo)
                    
                    let vm: StarredWorkerEmployCardVM = .init(
                        postId: vo.postId,
                        vo: cardVO,
                        coordinator: self.coordinator
                    )
                    
                    return vm
                }
                
                return viewModels
            }
            .asDriver(onErrorJustReturn: [])
        
        alert = requestPostFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "즐겨찾기한 공고 불러오기 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    
    func publishStarredPostMocks() -> Single<Result<[RecruitmentPostForWorkerVO], DomainError>> {
        return .just(.success((0..<10).map { _ in .mock }))
    }
}

class StarredWorkerEmployCardVM: WorkerEmployCardViewModelable {
    
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
        let applicationInformation: BehaviorRelay<ApplicationInfo> = .init(
            value: .init(
                isApplied: false,
                applicationDateText: ""
            )
        )
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
