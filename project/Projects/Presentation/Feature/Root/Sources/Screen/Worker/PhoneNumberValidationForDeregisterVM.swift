//
//  PhoneNumberValidationForDeregisterVM.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import Foundation
import Domain
import AuthFeature
import BaseFeature


import RxCocoa
import RxSwift


public protocol PhoneNumberValidationForDeregisterVMable: BaseViewModel, AuthPhoneNumberInputable & AuthPhoneNumberOutputable {
    
    var backButtonClicked: PublishRelay<Void> { get }
    var cancelButtonClicked: PublishRelay<Void> { get }
    var deregisterButtonClicked: PublishRelay<Void> { get }
}

class PhoneNumberValidationForDeregisterVM: BaseViewModel, PhoneNumberValidationForDeregisterVMable {
    
    var loginSuccess: RxCocoa.Driver<Void>?
    
    // Init
    weak var coordinator: PhoneNumberValidationForDeregisterCoordinator?
    let inputValidationUseCase: AuthInputValidationUseCase
    let settingUseCase: SettingScreenUseCase
    
    // Input
    var editingPhoneNumber: RxRelay.BehaviorRelay<String> = .init(value: "")
    var editingAuthNumber: RxRelay.BehaviorRelay<String> = .init(value: "")
    var requestAuthForPhoneNumber: RxRelay.PublishRelay<Void> = .init()
    var requestValidationForAuthNumber: RxRelay.PublishRelay<Void> = .init()
    var deregisterButtonClicked: RxRelay.PublishRelay<Void> = .init()
    var backButtonClicked: RxRelay.PublishRelay<Void> = .init()
    var cancelButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    // Output
    var canSubmitPhoneNumber: RxCocoa.Driver<Bool>?
    var canSubmitAuthNumber: RxCocoa.Driver<Bool>?
    var phoneNumberValidation: RxCocoa.Driver<Bool>?
    var authNumberValidation: RxCocoa.Driver<Bool>?
    var loginValidation: RxCocoa.Driver<Void>?
    
    init(
            coordinator: PhoneNumberValidationForDeregisterCoordinator?,
            deregisterReasons: [String],
            inputValidationUseCase: AuthInputValidationUseCase,
            settingUseCase: SettingScreenUseCase
        )
    {
        self.coordinator = coordinator
        self.inputValidationUseCase = inputValidationUseCase
        self.settingUseCase = settingUseCase
        
        super.init()
        
        // MARK: 번호인증 로직
        AuthInOutStreamManager.validatePhoneNumberInOut(
            input: self,
            output: self,
            useCase: inputValidationUseCase,
            disposeBag: disposeBag
        ) { _ in }
        
        let deregisterResult = deregisterButtonClicked
            .flatMap { [settingUseCase] _ in
                settingUseCase
                    .deregisterWorkerAccount(reasons: deregisterReasons)
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
        
        let deregisterFailureAlert = deregisterFailure
            .map {
                DefaultAlertContentVO(
                    title: "회원탈퇴 실패",
                    message: $0.message
                )
            }
        
        Observable
            .merge(deregisterFailureAlert)
            .subscribe(alert)
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
    }
}
