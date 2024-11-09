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

class MakeCenterProfileOverviewViewModel: BaseViewModel {
    
    // Injection
    @Injected var profileUseCase: CenterProfileUseCase
    
    // Navigation
    var presentCompleteScreen: ((AnonymousCompleteVCRenderObject) -> ())?
    var presentCenterMainPage: (() -> ())?
    var exitPage: (() -> ())?
    
    // input
    let backButtonClicked: PublishSubject<Void> = .init()
    let requestProfileRegister: PublishSubject<Void> = .init()
    
    // output
    var renderObject: CenterProfileRegisterState
    
    
    init(stateObject: CenterProfileRegisterState) {
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
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposeBag)
        
        registerResult
            .unretained(self)
            .subscribe(onNext: { (obj, result) in
        
            switch result {
            case .success:
                let object = AnonymousCompleteVCRenderObject(
                    titleText: "센터 정보를 등록했어요!",
                    descriptionText: "",
                    completeButtonText: "확인") { [weak self] in
                        self?.presentCenterMainPage?()
                    }
                obj.presentCompleteScreen?(object)
                
            case .failure(let error):
                let alertVO = DefaultAlertContentVO(
                    title: "프로필 등록 오류",
                    message: error.message
                )
                
                obj.alert.onNext(alertVO)
            }
        })
        .disposed(by: disposeBag)
    }
}
