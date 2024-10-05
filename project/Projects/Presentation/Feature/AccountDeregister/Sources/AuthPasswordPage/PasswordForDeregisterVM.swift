//
//  PasswordForDeregisterVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/21/24.
//

import Foundation
import BaseFeature
import Domain
import Core


import RxCocoa
import RxSwift

public class PasswordForDeregisterVM: BaseViewModel {

    // Injection
    @Injected var settingUseCase: SettingScreenUseCase
    
    // Navigation
    var changeToAuthFlow: (() -> ())?
    var backToSettingPage: (() -> ())?
    var exitPage: (() -> ())?
    
    public let deregisterButtonClicked: PublishRelay<String> = .init()
    public let backButtonClicked: PublishRelay<Void> = .init()
    public let cancelButtonClicked: PublishRelay<Void> = .init()
    
    public init(reasons: [String]) {
        super.init()
        
        let deregisterResult = deregisterButtonClicked
            .unretained(self)
            .flatMap { (obj, password) in
                obj.settingUseCase.deregisterWorkerAccount(reasons: reasons)
            }
            .share()
        
        let deregisterSuccess = deregisterResult.compactMap { $0.value }
        let deregisterFailure = deregisterResult.compactMap { $0.error }

        deregisterSuccess
            .observe(on: MainScheduler.asyncInstance)
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                // 회원탈퇴 성공 -> 원격알림 토큰 제거
                NotificationCenter.default.post(name: .requestDeleteTokenFromServer, object: nil)
                
                // RootCoordinator로 이동
                obj.backToSettingPage?()
            })
            .disposed(by: disposeBag)
        
        backButtonClicked
            .observe(on: MainScheduler.instance)
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposeBag)
        
        cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.backToSettingPage?()
            })
            .disposed(by: disposeBag)
        
        deregisterFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "회원탈퇴 실패",
                    message: error.message
                )
            }
            .subscribe(alert)
            .disposed(by: disposeBag)
    }
}
