//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import RxCocoa
import UseCaseInterface
import Entity
import PresentationCore

public class CenterLoginViewModel: ViewModelType {
    
    // Init
    let authUseCase: AuthUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    var validPassword: String?
    
    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
        
        setObservable()
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    func setObservable() {
        
        output.canRequestLoginAction = Observable
            .combineLatest(
                input.editingId,
                input.editingPassword
            )
            .map { (id, password) in
                return !id.isEmpty && !password.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        let loginResult = input
            .loginButtonPressed
            .flatMap { [unowned self, input] _ in
                let id = input.editingId.value
                let password = input.editingPassword.value
                return self.authUseCase
                    .loginCenterAccount(id: id, password: password)
            }
            .share()
        
        output.loginValidation = loginResult
            .map { result in
                
                switch result {
                case .success:
                    printIfDebug("✅ 로그인 성공")
                    return true
                case .failure(let error):
                    printIfDebug("❌ 로그인 실패: \(error.message)")
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
    }
}

public extension CenterLoginViewModel {
    
    class Input {
        public let editingId: BehaviorRelay<String> = .init(value: "")
        public let editingPassword: BehaviorRelay<String> = .init(value: "")
        public let loginButtonPressed: PublishRelay<Void> = .init()
    }
    
    class Output {
        public var canRequestLoginAction: Driver<Bool>?
        public var loginValidation: Driver<Bool>?
    }
}
