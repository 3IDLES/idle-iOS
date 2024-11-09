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
    @Injected var centerProfileUseCase: CenterProfileUseCase
    
    // Navigation
    var exitPage: (() -> ())?
    var presentAlert: ((DefaultAlertObject) -> ())?
    var presentSetupNewPasswordPage: (() -> ())?
    var presentCenterMainPage: (() -> ())?
    var presentCertificatePage: (() -> ())?
    var presentMakeCenterProfilePage: (() -> ())?
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    public override init() {
        
        super.init()
        
        // MARK: input
        input.backButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposeBag)
        
        input.setNewPasswordButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentSetupNewPasswordPage?()
            })
            .disposed(by: disposeBag)
        
        let loginResult = mapEndLoading(mapStartLoading(input.loginButtonPressed.asObservable())
            .flatMap { [unowned self, input] _ in
                let id = input.editingId.value
                let password = input.editingPassword.value
                return self.authUseCase
                    .loginCenterAccount(id: id, password: password)
            })
            .share()
        
        let loginSuccess = loginResult.compactMap { $0.value }
        let loginFailure = loginResult.compactMap { $0.error }
        
        
        let checkCenterJoinStatusResult = loginSuccess
            .unretained(self)
            .flatMap { (vm, _) in
                vm.authUseCase.checkCenterJoinStatus()
            }
            .share()
        
        let checkStatusSuccess = checkCenterJoinStatusResult.compactMap { $0.value }
        let checkStatusFailure = checkCenterJoinStatusResult.compactMap { $0.error }
        
        let checkProfileRegisterResult = checkStatusSuccess
            .unretained(self)
            .compactMap { (vm, vo) -> Void? in
                
                let status = vo.centerManagerAccountStatus
                
                switch status {
                case .new, .pending:
                    vm.presentCertificatePage?()
                    return nil
                case .approved:
                    return ()
                }
            }
            .unretained(self)
            .flatMap { (vm, _) in
                vm.centerProfileUseCase
                    .getProfile(mode: .myProfile)
            }
            .share()
        
        let profileExists = checkProfileRegisterResult.compactMap { $0.value }
        let profileDoentExistOrError = checkProfileRegisterResult.compactMap { $0.error }
        
        profileExists
            .unretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.presentCenterMainPage?()
            })
            .disposed(by: disposeBag)
        
        
        let checkProfileExistenceFailure = profileDoentExistOrError
            .unretained(self)
            .compactMap { (vm, error) -> DomainError? in
                
                switch error {
                case .centerNotFoundException:
                    
                    // 센터가 없는 경우 -> 프로필이 등록되지 않음
                    // 프로필 등록화면으로 이동
                    vm.presentMakeCenterProfilePage?()
                    return nil
                default:
                    // 토큰과 무관한 에러상황
                    return error
                }
            }
        
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
        Observable
            .merge(
                loginFailure,
                checkStatusFailure,
                checkProfileExistenceFailure
            )
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
