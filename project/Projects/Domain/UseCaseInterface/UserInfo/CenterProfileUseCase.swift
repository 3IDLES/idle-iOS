//
//  CenterProfileUseCase.swift
//  UseCaseInterface
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity

/// 1. 나의 센터 프로필 정보 조회
/// 2. 센터 프로필 정보 업데이트(전화번호, 센터소개글)
/// 3. 센터 프로필 정보 업데이트(이미지, pre-signed-url)
/// 4. 센터 프로필 정보 업데이트(이미지, pre-signed-url-callback)
/// 5. 센터 프로필 최초 등록
/// 6. 특정 센터의 프로필 불러오기

public protocol CenterProfileUseCase: UseCaseBase {
    
    /// 1. 나의 센터/다른 센터 프로필 정보 조회
    func getProfile(mode: ProfileMode) -> Single<Result<CenterProfileVO, UserInfoError>>
    
    /// 2. 센터 프로필 정보 업데이트(전화번호, 센터소개글)
    /// 3. 센터 프로필 정보 업데이트(이미지, pre-signed-url)
    /// 4. 센터 프로필 정보 업데이트(이미지, pre-signed-url-callback)
    func updateProfile(phoneNumber: String?, introduction: String?, imageInfo: ImageUploadInfo?) -> Single<Result<Void, UserInfoError>>
    
    /// 5. 센터 프로필 최초 등록
    func registerCenterProfile(state: CenterProfileRegisterState) -> Single<Result<Void, UserInfoError>>
}
