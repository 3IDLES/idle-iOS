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

public class PasswordForDeregisterVM: DefaultAlertOutputable {

    public weak var coordinator: PasswordForDeregisterCoordinator?
    
    public let deregisterButtonClicked: PublishRelay<String> = .init()
    public let exitButtonClicked: PublishRelay<Void> = .init()
    public var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?
    
    let settingUseCase: SettingScreenUseCase
    
    let disposeBag = DisposeBag()
    
    public init(
        deregisterReasons: [DeregisterReasonVO],
        coordinator: PasswordForDeregisterCoordinator,
        settingUseCase: SettingScreenUseCase
    ) {
        self.coordinator = coordinator
        self.settingUseCase = settingUseCase
        
        let deregisterResult = deregisterButtonClicked
            .flatMap { [settingUseCase] password in
                settingUseCase.deregisterCenterAccount(
                    reasons: deregisterReasons,
                    password: password
                )
            }
            .share()
        
        let deregisterSuccess = deregisterResult.compactMap { $0.value }
        let deregisterFailure = deregisterResult.compactMap { $0.error }

        deregisterSuccess
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                
                // ‼️ ‼️ 로컬에 저장된 계정 정보 삭제 ‼️ ‼️
                
                // RootCoordinator로 이동
                self?.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
        
        exitButtonClicked
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
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
