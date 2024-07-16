//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import RxCocoa
import UseCaseInterface
import PresentationCore

public class CenterLoginViewModel: ViewModelType {
    
    // Init
    let authUseCase: AuthUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
        
        setObservable()
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    private func setObservable() {
        
        let loginResult = input
            .loginButtonPressed
            .compactMap { $0 }
            .flatMap { [unowned self] (id, pw) in
                self.authUseCase
                    .loginCenterAccount(id: id, password: pw)
            }
            .share()
        
        _ = loginResult
            .compactMap { $0.value }
            .map { _ in
                printIfDebug("✅ 로그인 성공")
                return true
            }
            .bind(to: output.loginValidation)
        
        _ = loginResult
            .compactMap { $0.error }
            .map { error in
                printIfDebug("❌ 로그인 실패, 에러내용: \(error.message)")
                return false
            }
            .bind(to: output.loginValidation)
    }
}


public extension CenterLoginViewModel {
    
    struct Input {
        
        public var loginButtonPressed: PublishRelay<(id: String, pw: String)?> = .init()
        
    }
    
    struct Output {
        
        public var loginValidation: PublishSubject<Bool?> = .init()
    }
}
