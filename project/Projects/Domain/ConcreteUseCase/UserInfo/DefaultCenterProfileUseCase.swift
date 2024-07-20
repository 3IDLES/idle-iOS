//
//  DefaultCenterProfileUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefaultCenterProfileUseCase: CenterProfileUseCase {
    
    let repository: UserProfileRepository
    
    public init(repository: UserProfileRepository) {
        self.repository = repository
    }
    
    public func getProfile() -> Single<Result<CenterProfileVO, UserInfoError>> {
        
        convert(task: repository
            .getMyProfile(.center)) { [unowned self] error in
                toDomainError(error: error)
            }
        
    }
}
