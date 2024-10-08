//
//  PhoneNumberValidationForDeregisterVM.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 8/25/24.
//

import Foundation
import Domain
import BaseFeature
import Core


import RxCocoa
import RxSwift


public protocol PhoneNumberValidationForDeregisterVMable: BaseViewModel, AuthPhoneNumberInputable & AuthPhoneNumberOutputable {
    
    var backButtonClicked: PublishRelay<Void> { get }
    var cancelButtonClicked: PublishRelay<Void> { get }
    var deregisterButtonClicked: PublishRelay<Void> { get }
}

class PhoneNumberValidationForDeregisterVM: BaseViewModel, PhoneNumberValidationForDeregisterVMable {
    
    @Injected var inputValidationUseCase: AuthInputValidationUseCase
    @Injected var settingUseCase: SettingScreenUseCase
    
    // Navigation
    var changeToAuthFlow: (() -> ())?
    var backToPrevModule: (() -> ())?
    var exitPage: (() -> ())?
    
    
    // Input
    var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
    var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
    var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
    var requestValidationForAuthNumber: PublishRelay<Void> = .init()
    var deregisterButtonClicked: PublishRelay<Void> = .init()
    var backButtonClicked: PublishRelay<Void> = .init()
    var cancelButtonClicked: PublishRelay<Void> = .init()
    
    // Output
    var loginSuccess: Driver<Void>?
    var canSubmitPhoneNumber: Driver<Bool>?
    var canSubmitAuthNumber: Driver<Bool>?
    var phoneNumberValidation: Driver<Bool>?
    var authNumberValidation: Driver<Bool>?
    var loginValidation: Driver<Void>?
    
    init(reasons: [String]) {
        
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
                    .deregisterWorkerAccount(reasons: reasons)
            }
            .share()
        
        let deregisterSuccess = deregisterResult.compactMap { $0.value }
        let deregisterFailure = deregisterResult.compactMap { $0.error }
        
        deregisterSuccess
            .observe(on: MainScheduler.asyncInstance)
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                // RootCoordinator로 이동
                obj.changeToAuthFlow?()
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
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposeBag)
        
        cancelButtonClicked
            .observe(on: MainScheduler.instance)
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.backToPrevModule?()
            })
            .disposed(by: disposeBag)
    }
}
