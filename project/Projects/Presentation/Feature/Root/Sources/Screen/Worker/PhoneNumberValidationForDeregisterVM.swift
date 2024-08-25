//
//  PhoneNumberValidationForDeregisterVM.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import Foundation
import RxCocoa
import RxSwift
import Entity
import AuthFeature
import UseCaseInterface


public protocol PhoneNumberValidationForDeregisterVMable: AuthPhoneNumberInputable & AuthPhoneNumberOutputable { 
    
    var backButtonClicked: PublishRelay<Void> { get }
    var cancelButtonClicked: PublishRelay<Void> { get }
    var deregisterButtonClicked: PublishRelay<Void> { get }
}

class PhoneNumberValidationForDeregisterVM: PhoneNumberValidationForDeregisterVMable {
    
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
    var alert: RxCocoa.Driver<Entity.DefaultAlertContentVO>?

    let disposeBag = DisposeBag()
    
    init(
            coordinator: PhoneNumberValidationForDeregisterCoordinator?,
            deregisterReasons: [DeregisterReasonVO],
            inputValidationUseCase: AuthInputValidationUseCase,
            settingUseCase: SettingScreenUseCase
        )
    {
        self.coordinator = coordinator
        self.inputValidationUseCase = inputValidationUseCase
        self.settingUseCase = settingUseCase
        
        // MARK: 번호인증 로직
        AuthInOutStreamManager.validatePhoneNumberInOut(
            input: self,
            output: self,
            useCase: inputValidationUseCase) { _ in }
        
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
                
                // ‼️ ‼️ 로컬에 저장된 계정 정보 삭제 ‼️ ‼️
                
                // RootCoordinator로 이동
                self?.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
        
        if let alert {
            
            self.alert = Observable
                .merge(
                    alert.asObservable(),
                    deregisterFailure
                        .map {
                            DefaultAlertContentVO(
                                title: "회원탈퇴 실패",
                                message: $0.message
                            )
                        }
                )
                .asDriver(onErrorJustReturn: .default)
        }
        
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
