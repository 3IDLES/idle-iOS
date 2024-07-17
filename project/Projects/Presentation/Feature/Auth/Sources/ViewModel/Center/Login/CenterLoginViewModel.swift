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
            .map { [weak self] _ in
                printIfDebug("✅ 로그인 성공")
                
                self?.output.loginValidation.accept(true)
            }
        
        _ = loginResult
            .compactMap { $0.error }
            .map { [weak self] error in
                printIfDebug("❌ 로그인 실패, 에러내용: \(error.message)")
                
                self?.output.loginValidation.accept(false)
            }
    }
}

public extension CenterLoginViewModel {
    
    class Input {
        
        public var loginButtonPressed: PublishRelay<(id: String, pw: String)?> = .init()
    }
    
    class Output {
        
        public var loginValidation: PublishRelay<Bool?> = .init()
    }
}
