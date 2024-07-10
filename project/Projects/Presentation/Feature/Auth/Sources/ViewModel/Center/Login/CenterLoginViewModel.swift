//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import UseCaseInterface
import PresentationCore

public class CenterLoginViewModel: ViewModelType {
    
    // Init
    let authUseCase: AuthUseCase
    
    public var input: Input = .init()
    private var output: Output = .init()
    
    private let disposeBag = DisposeBag()
    
    public init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
    
    public func transform(input: Input) -> Output {
        
        input
            .loginButtonPressed?
            .subscribe { [weak self] (id, pw) in
                
                guard let self else { return }
                
                self.authUseCase
                    .loginCenterAccount(id: id, password: pw)
                    .subscribe(onNext: { [weak self] result in
                        
                        switch result {
                        case .success(_):
                            printIfDebug("✅ 로그인 성공")
                            self?.output.loginValidation?.onNext(true)
                        case .failure(let error):
                            printIfDebug("❌ 로그인 실패, 에러내용: \(error.message)")
                            self?.output.loginValidation?.onNext(false)
                        }
                    })
                    .disposed(by: self.disposeBag)
                
            }
            .disposed(by: disposeBag)
            
        
        return self.output
    }
}


public extension CenterLoginViewModel {
    
    struct Input {
        
        public var loginButtonPressed: Observable<(id: String, pw: String)>?
        
    }
    
    struct Output {
        
        public var loginValidation: PublishSubject<Bool>? = .init()
    }
}
