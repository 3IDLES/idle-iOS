//
//  CenterCertificateUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 9/11/24.
//

import Foundation

import RxSwift

public protocol CenterCertificateUseCase: BaseUseCase {
    
    /// 센터 로그아웃
    func signoutCenterAccount() -> Single<Result<Void, DomainError>>
    
    /// 요양보호사 로그아웃
    func signoutWorkerAccount() -> Single<Result<Void, DomainError>>
    
    /// 센터 인증 요청
    func requestCenterCertificate() -> Single<Result<Void, DomainError>>
    
    /// 센터 상태확인
    func getCenterJoinStatus() -> Single<Result<CenterJoinStatusInfoVO, DomainError>>
}
