//
//  NotificationTokenTransportRepository.swift
//  Domain
//
//  Created by choijunios on 10/8/24.
//

import Foundation


import RxSwift

public protocol NotificationTokenTransferRepository: RepositoryBase {
    
    func sendToken(token: String, userType: UserType) -> Single<Result<Void, DomainError>>
    func deleteToken(token: String) -> Single<Result<Void, DomainError>>
}
