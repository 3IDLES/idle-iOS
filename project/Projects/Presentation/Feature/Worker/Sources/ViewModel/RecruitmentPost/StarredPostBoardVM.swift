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

public class StarredPostBoardVM: BaseViewModel, WorkerAppliablePostBoardVMable {
    
    // Input
    public var requestInitialPageRequest: RxRelay.PublishRelay<Void> = .init()
    public var requestNextPage: RxRelay.PublishRelay<Void> = .init()
    public var applyButtonClicked: RxRelay.PublishRelay<(postId: String, postTitle: String)> = .init()
    
    // Output
    public var postBoardData: RxCocoa.Driver<BoardRefreshResult>?
    public var idleAlertVM: RxCocoa.Driver<IdleAlertViewModelable>?
    
    // Init
    public weak var coordinator: WorkerRecruitmentBoardCoordinatable?
    public let recruitmentPostUseCase: RecruitmentPostUseCase
    
    public init(coordinator: WorkerRecruitmentBoardCoordinatable, recruitmentPostUseCase: RecruitmentPostUseCase) {
        self.coordinator = coordinator
        self.recruitmentPostUseCase = recruitmentPostUseCase
        
        super.init()
        
        // MARK: 공고리스트 처음부터 요청하기
        let initialRequestResult = requestInitialPageRequest
            .flatMap { [weak self, recruitmentPostUseCase] _ in
                
                self?.showLoading.onNext(())
                
                return recruitmentPostUseCase
                    .getFavoritePostListForWorker()
            }
            .share()
        
        initialRequestResult
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                dismissLoading.onNext(())
            })
            .disposed(by: disposeBag)
        
        let initialRequestSuccess = initialRequestResult.compactMap { $0.value }
        let initialRequestFailure = initialRequestResult.compactMap { $0.error }
        
        postBoardData = initialRequestSuccess
            .map({ list in
                
                let sortedList = list.sorted { lhs, rhs in
                    guard let lhsDate = lhs.beFavoritedTime, let rhsDate = rhs.beFavoritedTime else {
                        return false
                    }
                    
                    // 최신값을 배열의 앞쪽(화면의 상단)에 노출
                    
                    return lhsDate > rhsDate
                }
                
                return (true, sortedList)
            })
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: 지원하기
        let applyRequest: PublishRelay<String> = .init()
        
        self.idleAlertVM = applyButtonClicked
            .map { (postId: String, postTitle: String) in
                DefaultIdleAlertVM(
                    title: "'postTitle'\n공고에 지원하시겠어요?",
                    description: "",
                    acceptButtonLabelText: "지원하기",
                    cancelButtonLabelText: "취소하기") { [applyRequest] in
                        applyRequest.accept(postId)
                    }
            }
            .asDriver(onErrorDriveWith: .never())
            
        let applyRequestResult = applyRequest
            .flatMap { [weak self, recruitmentPostUseCase] postId in
                
                self?.showLoading.onNext(())
                
                // 리스트화면에서는 앱내 지원만 지원합니다.
                return recruitmentPostUseCase
                    .applyToPost(postId: postId, method: .app)
            }
            .share()
        
        
        let applyRequestFailure = applyRequestResult.compactMap { $0.error }
        
        let applyRequestFailureAlert = applyRequestFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "지원하기 실패",
                    message: error.message
                )
            }
        
        let requestPostListFailureAlert = initialRequestFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "즐겨찾기한 공고 불러오기 오류",
                    message: error.message
                )
            }
        
        Observable
            .merge(applyRequestFailureAlert, requestPostListFailureAlert)
            .subscribe(onNext: { [weak self] alertVO in
                guard let self else { return }
                alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
        
        // MARK: 로딩 종료
        Observable
            .merge(
                initialRequestResult.map({ _ in }),
                applyRequestResult.map({ _ in })
            )
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                dismissLoading.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
