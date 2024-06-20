//
//  UseCase.swift
//  Idle-iOSManifests
//
//  Created by 최준영 on 6/20/24.
//

import Foundation
import DomainInterface
import RepositoryInterface

public class DefaultUseCase: UseCaseInterface {
    
    private let repository: RepositoryInterface
    
    public init(repository: RepositoryInterface) {
        self.repository = repository
    }
    
    public func sayHello() {
        let message = repository.getHelloMessage()
        
        print(message)
    }
}
