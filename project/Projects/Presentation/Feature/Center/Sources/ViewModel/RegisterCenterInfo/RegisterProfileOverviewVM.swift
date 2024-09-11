//
//  RegisterProfileOverviewVM.swift
//  CenterFeature
//
//  Created by choijunios on 9/12/24.
//

import Foundation
import BaseFeature
import Entity
import UseCaseInterface
import PresentationCore

import RxSwift
import RxCocoa

public class RegisterProfileOverviewVM: BaseViewModel {
    
    // Init
    weak var coordinator: ProfileRegisterOverviewCO?
    let profileUseCase: CenterProfileUseCase
    
    // input
    let backButtonClicked: PublishSubject<Void> = .init()
    let requestProfileRegister: PublishSubject<Void> = .init()
    
    // output
    var renderObject: CenterProfileRegisterState
    
    
    init(
        coordinator: ProfileRegisterOverviewCO,
        stateObject: CenterProfileRegisterState,
        profileUseCase: CenterProfileUseCase
    ) {
        self.coordinator = coordinator
        self.renderObject = stateObject
        self.profileUseCase = profileUseCase
        
        super.init()
        
        let registerResult = mapEndLoading(mapStartLoading(requestProfileRegister)
            .flatMap { [profileUseCase, stateObject] _ in
                profileUseCase
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
