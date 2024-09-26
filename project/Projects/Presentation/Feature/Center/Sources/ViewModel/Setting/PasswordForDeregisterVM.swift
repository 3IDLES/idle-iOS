//
//  PasswordForDeregisterVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/21/24.
//

import Foundation
import BaseFeature
import UseCaseInterface
import Entity


import RxCocoa
import RxSwift

public class PasswordForDeregisterVM: BaseViewModel {

    public weak var coordinator: PasswordForDeregisterCoordinator?
    
    public let deregisterButtonClicked: PublishRelay<String> = .init()
    public let backButtonClicked: PublishRelay<Void> = .init()
    public let cancelButtonClicked: PublishRelay<Void> = .init()
    
    let settingUseCase: SettingScreenUseCase
    
    public init(
        deregisterReasons: [String],
        coordinator: PasswordForDeregisterCoordinator,
        settingUseCase: SettingScreenUseCase
    ) {
        self.coordinator = coordinator
        self.settingUseCase = settingUseCase
        
        super.init()
        
        let deregisterResult = deregisterButtonClicked
            .flatMap { [settingUseCase] password in
                settingUseCase.deregisterWorkerAccount(reasons: deregisterReasons)
            }
            .share()
        
        let deregisterSuccess = deregisterResult.compactMap { $0.value }
        let deregisterFailure = deregisterResult.compactMap { $0.error }

        deregisterSuccess
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                
                // 회원탈퇴 성공 -> 원격알림 토큰 제거
                NotificationCenter.default.post(name: .requestDeleteTokenFromServer, object: nil)
                
                // RootCoordinator로 이동
                self?.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
        
        backButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.cancelDeregister()
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
