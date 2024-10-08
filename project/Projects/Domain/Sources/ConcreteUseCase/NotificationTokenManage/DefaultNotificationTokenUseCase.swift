//
//  DefaultNotificationTokenUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 9/26/24.
//

import Foundation
import Core


import RxSwift

public class DefaultNotificationTokenUseCase: NotificationTokenUseCase {
    
    // Repositories
    @Injected var tokenTransferRepository: NotificationTokenTransferRepository
    @Injected var tokenRepository: NotificationTokenRepository
    @Injected var userInfoLocalRepository: UserInfoLocalRepository
    
    let disposeBag = DisposeBag()
    
    public init() {
        // set deleage
        self.tokenRepository.delegate = self
    }
    
    public func setNotificationToken() -> Single<Result<Void, DomainError>> {
        
        guard let userType = userInfoLocalRepository.getUserType() else {
            return .just(.failure(.clientException))
        }
        
        let notificationToken = tokenRepository.getToken()
        
        return tokenTransferRepository
            .sendToken(token: notificationToken, userType: userType)
    }
    
    public func deleteNotificationToken() -> Single<Result<Void, DomainError>> {
        
        let notificationToken = tokenRepository.getToken()
        
        return tokenTransferRepository
            .deleteToken(token: notificationToken)
    }
}

extension DefaultNotificationTokenUseCase: NotificationTokenRepositoryDelegate {
    
    public func notificationToken(freshToken: String) {
        setNotificationToken()
            .subscribe { result in
                
                switch result {
                case .success:
                    printIfDebug("자동 리프래쉬 토큰 전송 성공")
                case .failure(let error):
                    printIfDebug("자동 리프래쉬 토큰 전송 실패: \(error.localizedDescription)")
                }
                
            }
            .disposed(by: disposeBag)
    }
}
