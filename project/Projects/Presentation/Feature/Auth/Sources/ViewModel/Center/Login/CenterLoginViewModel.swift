//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import BaseFeature
import UseCaseInterface
import RepositoryInterface
import Entity
import PresentationCore


import RxSwift
import RxCocoa

public class CenterLoginViewModel: BaseViewModel, ViewModelType {
    
    // Init
    weak var coordinator: CenterLoginCoordinator?
    let authUseCase: AuthUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    public init(coordinator: CenterLoginCoordinator?, authUseCase: AuthUseCase) {
        self.coordinator = coordinator
        self.authUseCase = authUseCase
        
        super.init()
        
        // MARK: input
        input.backButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
        
        input.setNewPasswordButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.showSetNewPasswordScreen()
            })
            .disposed(by: disposeBag)
        
        let loginResult = input.loginButtonPressed
            .flatMap { [unowned self, input] _ in
                let id = input.editingId.value
                let password = input.editingPassword.value
                return self.authUseCase
                    .loginCenterAccount(id: id, password: password)
            }
            .share()
        
        let loginSuccess = loginResult.compactMap { $0.value }
        let loginFailure = loginResult.compactMap { $0.error }
        
        
        loginSuccess
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                // 원격 알림 토큰 저장요청
                NotificationCenter.default.post(name: .requestTransportTokenToServer, object: nil)
                
                self.coordinator?.authFinished()
            })
            .disposed(by: disposeBag)
        
        // MARK: output
        output.canRequestLoginAction = Observable
            .combineLatest(
                input.editingId,
                input.editingPassword
            )
            .map { (id, password) in
                return !id.isEmpty && !password.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        
        // MARK: BaseViewModel
        loginFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "로그인 실패",
                    message: error.message
                )
            }
            .subscribe(alert)
            .disposed(by: disposeBag)
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

public extension CenterLoginViewModel {
    
    class Input {
        public let editingId: BehaviorRelay<String> = .init(value: "")
        public let editingPassword: BehaviorRelay<String> = .init(value: "")
        public let loginButtonPressed: PublishRelay<Void> = .init()
        public let backButtonClicked: PublishRelay<Void> = .init()
        public let setNewPasswordButtonClicked: PublishRelay<Void> = .init()
    }
    
    class Output {
        public var canRequestLoginAction: Driver<Bool>?
    }
}
