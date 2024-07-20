//
//  CenterProfileUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity

/// 1. 센터 프로필 정보 조회
/// 2. 센터 프로필 정보 업데이트(전화번호, 센터소개글)
/// 3. 센터 프로필 정보 업데이트(이미지, pre-signed-url)
/// 4. 센터 프로필 정보 업데이트(이미지, pre-signed-url-callback)


public protocol CenterProfileUseCase: UseCaseBase {
    
    func getProfile() -> Single<Result<CenterProfileVO, UserInfoError>>
}
