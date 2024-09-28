//
//  RemoteConfigRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 9/13/24.
//

import Foundation


import RxSwift

public protocol RemoteConfigRepository: RepositoryBase {
    
    /// RemoteConfig를 fetch합니다.
    func fetchRemoteConfig() -> Single<Result<Bool, Error>>
    
    /// 강제업데이트 정보를 가져옵니다.
    func getForceUpdateInfo() -> ForceUpdateInfo?
}
