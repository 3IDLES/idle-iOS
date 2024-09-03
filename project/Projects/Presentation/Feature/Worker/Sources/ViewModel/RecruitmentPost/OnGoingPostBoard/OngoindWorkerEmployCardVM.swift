//
//  ViewModelForCell.swift
//  WorkerFeature
//
//  Created by choijunios on 9/2/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import UseCaseInterface


// MARK: ViewModelForCell
class OngoindWorkerEmployCardVM: WorkerEmployCardViewModelable {
    
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
