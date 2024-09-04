//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import BaseFeature
import RxCocoa
import UseCaseInterface
import RepositoryInterface
import Entity
import PresentationCore

public class CenterLoginViewModel: BaseViewModel, ViewModelType {
    
    // Init
    weak var coordinator: CenterLoginCoordinator?
    let authUseCase: AuthUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    let disposeBag = DisposeBag()
    
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
        alert = loginFailure
            .map { error in
                DefaultAlertContentVO(
                    title: "로그인 실패",
                    message: error.message
                )
            }
            .asDriver(onErrorJustReturn: .default)
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
