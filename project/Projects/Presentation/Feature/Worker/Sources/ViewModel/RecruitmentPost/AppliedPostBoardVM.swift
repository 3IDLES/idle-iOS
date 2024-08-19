//
//  AppliedPostBoardVM.swift
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


public class AppliedPostBoardVM: WorkerStaticPostBoardVMable {
    
    var postViewWillAppear: RxRelay.PublishRelay<Void> = .init()
    
    var postBoardData: RxCocoa.Driver<[any DSKit.WorkerEmployCardViewModelable]>?
    var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    // Init
    weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        let requestPostResult = postViewWillAppear
            .flatMap { [unowned self] _ in
                self.publishAppliedPostMocks()
            }
            .share()
        
        let requestPostSuccess = requestPostResult.compactMap { $0.value }
        let requestPostFailure = requestPostResult.compactMap { $0.error }
        
        postBoardData = requestPostSuccess
            .map { postForWorkerVos in
                
                // ViewModel 생성
                let viewModels = postForWorkerVos.map { vo in
                    
                    let cardVO: WorkerEmployCardVO = .create(vo: vo)
                    
                    let vm: WorkerEmployCardVM = .init(
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
                    title: "지원한 공고 불러오기 오류",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
    
    
    func publishAppliedPostMocks() -> Single<Result<[RecruitmentPostForWorkerVO], RecruitmentPostError>> {
        return .just(.success((0..<10).map { _ in .mock }))
    }
}
