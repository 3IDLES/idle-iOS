//
//  DefaultNotificationTokenTransferRepository.swift
//  DataSource
//
//  Created by choijunios on 10/8/24.
//

import Foundation
import Domain


import RxSwift

public class DefaultNotificationTokenTransferRepository: NotificationTokenTransferRepository {
    
    let transferService: NotificationTokenTransferService = .init()
    
    public init() { }
    
    public func sendToken(token: String, userType: UserType) -> Single<Result<Void, DomainError>> {
        
        let userTypeString = userType == .center ? "CENTER" : "CARER"
        let dataTask = transferService
            .request(
                api: .saveToken(deviceToken: token, userType: userTypeString),
                with: .withToken
            )
            .mapToVoid()
        
        return convert(task: dataTask)
    }
    
    public func deleteToken(token: String) -> Single<Result<Void, DomainError>> {
        
        let dataTask = transferService
            .request(
                api: .deleteToken(deviceToken: token),
                with: .withToken
            )
            .mapToVoid()
        
        return convert(task: dataTask)
    }
}
