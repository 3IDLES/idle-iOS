//
//  DefaultUserProfileRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/20/24.
//

import RxSwift
import Entity
import RepositoryInterface
import NetworkDataSource

public class DefaultUserProfileRepository: UserProfileRepository {
    
    let service = UserInformationService()
    
    public init() { }
    
    public func getMyProfile(_ userType: UserType) -> Single<CenterProfileVO> {
        
        service
            .requestDecodable(api: .getCenterProfile, with: .withToken)
            .map { (dto: CenterProfileDTO) in dto.toEntity() }
    }
}
