//
//  RemoteConfigRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 9/13/24.
//

import Foundation
import RxSwift

public protocol RemoteConfigRepository: RepositoryBase {
    
    /// Remote config의 특정 키값에 매칭되는 값을 가져옵니다.
    func getConfigValue(key: String) -> Single<String?>
    
    /// Remote config가 변경되었는지 확인합니다.
    func checkConfigIsChange() -> Single<Bool>
}
