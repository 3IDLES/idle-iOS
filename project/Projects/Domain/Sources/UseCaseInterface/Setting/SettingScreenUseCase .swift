//
//  SettingScreenUseCase .swift
//  UseCaseInterface
//
//  Created by choijunios on 8/19/24.
//

import Foundation


import RxSwift

public protocol SettingScreenUseCase: BaseUseCase {

    // MARK: Worker
    
    /// 요양보호사 회원 탈퇴
    func deregisterWorkerAccount(
        reasons: [String]
    ) -> Single<Result<Void, DomainError>>
    
    /// 요양보호사 로그아웃
    func signoutWorkerAccount() -> Single<Result<Void, DomainError>>
    
    // MARK: Center
    
    /// 센터 회원 탈퇴
    func deregisterCenterAccount(
        reasons: [String],
        password: String
    ) -> Single<Result<Void, DomainError>>
    
    /// 센터 로그아웃
    func signoutCenterAccount() -> Single<Result<Void, DomainError>>
}
