//
//  OngoindWorkerEmployCardVM.swift
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
    
    // Init
    let postId: String
    var cellViewObject: Entity.WorkerNativeEmployCardVO
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    
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
