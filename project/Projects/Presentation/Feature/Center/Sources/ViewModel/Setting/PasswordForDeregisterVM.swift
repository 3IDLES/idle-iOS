//
//  PasswordForDeregisterVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/21/24.
//

import BaseFeature
import UseCaseInterface
import RxCocoa
import RxSwift
import Entity

public class PasswordForDeregisterVM: BaseViewModel {

    public weak var coordinator: PasswordForDeregisterCoordinator?
    
    public let deregisterButtonClicked: PublishRelay<String> = .init()
    public let backButtonClicked: PublishRelay<Void> = .init()
    public let cancelButtonClicked: PublishRelay<Void> = .init()
    
    let settingUseCase: SettingScreenUseCase
    
    let disposeBag = DisposeBag()
    
    public init(
        deregisterReasons: [DeregisterReasonVO],
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
        
        alert = deregisterFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "회원탈퇴 실패",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
    }
}
