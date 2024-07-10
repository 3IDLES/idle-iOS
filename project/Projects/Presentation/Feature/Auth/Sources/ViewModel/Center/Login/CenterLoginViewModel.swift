//
//  CenterLoginViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/10/24.
//

import RxSwift
import PresentationCore

public class CenterLoginViewModel: ViewModelType {
    
    public var input: Input = .init()
    
    public func transform(input: Input) -> Output {
        
        let output = Output()
        
        return output
    }
}


public extension CenterLoginViewModel {
    
    struct Input {
        
        public var editingId: Observable<String>?
        public var editingPassword: Observable<String>?
        
    }
    
    struct Output {
        
        public var loginValidation: Observable<String>?
        
    }
}
