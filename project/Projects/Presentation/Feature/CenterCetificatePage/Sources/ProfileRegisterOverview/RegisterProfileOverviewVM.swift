//
//  RegisterProfileOverviewVM.swift
//  CenterFeature
//
//  Created by choijunios on 9/12/24.
//

import Foundation
import BaseFeature
import Domain
import PresentationCore
import Core


import RxSwift
import RxCocoa

class RegisterProfileOverviewVM: BaseViewModel {
    
    @Injected var profileUseCase: CenterProfileUseCase
    
    // Init
    weak var coordinator: CenterProfileRegisterOverviewCoordinator?
    
    // input
    let backButtonClicked: PublishSubject<Void> = .init()
    let requestProfileRegister: PublishSubject<Void> = .init()
    
    // output
    var renderObject: CenterProfileRegisterState
    
    
    init(
        coordinator: CenterProfileRegisterOverviewCoordinator,
        stateObject: CenterProfileRegisterState
    ) {
        self.coordinator = coordinator
        self.renderObject = stateObject
        
        super.init()
        
        let registerResult = mapEndLoading(mapStartLoading(requestProfileRegister)
            .flatMap { [profileUseCase, stateObject] _ -> Single<Result<Void, DomainError>> in
                
                return profileUseCase
                    .registerCenterProfile(state: stateObject)
            })
            .share()
        
        backButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        registerResult.subscribe(onNext: { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success:
                coordinator.showCompleteScreen()
            case .failure(let error):
                let alertVO = DefaultAlertContentVO(
                    title: "프로필 등록 오류",
                    message: error.message
                )
                
                alert.onNext(alertVO)
            }
        })
        .disposed(by: disposeBag)
    }
}
