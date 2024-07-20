//
//  UserProfileRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity

public protocol UserProfileRepository: RepositoryBase {
    
    func getMyProfile(_ userType: UserType) -> Single<CenterProfileVO>
}
