//
//  WorkerProfileUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 8/10/24.
//

import Foundation
import RxSwift
import Entity

/// 1. 나의(요보) 프로필 정보 조회
/// 2. 나의(요보) 프로필 정보 업데이트(텍스트 데이터)
/// 3. 나의(요보) 프로필 정보 업데이트(이미지, pre-signed-url)
/// 4. 나의(요보) 프로필 정보 업데이트(이미지, pre-signed-url-callback)
/// 5. 특정 요양보호사의 프로필 불러오기

public protocol WorkerProfileUseCase: UseCaseBase {
    
    /// 1. 나의(요보) 프로필 정보 조회
    /// 5. 특정 요양보호사의 프로필 불러오기
    func getProfile(mode: ProfileMode) -> Single<Result<WorkerProfileVO, UserInfoError>>
    
    
    /// 2. 나의(요보) 프로필 정보 업데이트(텍스트 데이터)
    /// 3. 나의(요보) 프로필 정보 업데이트(이미지, pre-signed-url)
    /// 4. 나의(요보) 프로필 정보 업데이트(이미지, pre-signed-url-callback)
    func updateProfile(stateObject: WorkerProfileStateObject, imageInfo: ImageUploadInfo?) -> Single<Result<Void, UserInfoError>>

}
