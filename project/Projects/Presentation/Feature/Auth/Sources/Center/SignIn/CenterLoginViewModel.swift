//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import Foundation
import BaseFeature
import Domain
import PresentationCore
import Core

import RxSwift
import RxCocoa

public class CenterLoginViewModel: BaseViewModel, ViewModelType {
    
    // Injection
    @Injected var authUseCase: AuthUseCase
    
    // Navigation
    var exitPage: (() -> ())!
    var presentSetupNewPasswordPage: (() -> ())!
    var presentCenterMainPage: (() -> ())!
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    public override init() {
        
        super.init()
        
        // MARK: input
        input.backButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage()
            })
            .disposed(by: disposeBag)
        
        input.setNewPasswordButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentSetupNewPasswordPage()
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
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                // 원격 알림 토큰 저장요청
                NotificationCenter.default.post(name: .requestTransportTokenToServer, object: nil)
                
                // 센터 메인화면으로 이동
                obj.presentCenterMainPage()
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
