//
//  UserProfileRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/20/24.
//

import Foundation


import RxSwift

public protocol UserProfileRepository: RepositoryBase {

    // 센터 프로필 등록 (텍스트 정보)
    func registerCenterProfileForText(state: CenterProfileRegisterState) -> Single<Result<Void, DomainError>>

    // 센터 프로필 가져오기
    func getCenterProfile(mode: ProfileMode) -> Single<Result<CenterProfileVO, DomainError>>

    // 센터 프로필 업데이트 (텍스트 정보)
    func updateCenterProfileForText(phoneNumber: String, introduction: String?) -> Single<Result<Void, DomainError>>

    // 이미지 업로드
    func uploadImage(_ userType: UserType, imageInfo: ImageUploadInfo) -> Single<Result<Void, DomainError>>

    // 요양보호사 프로필 가져오기
    func getWorkerProfile(mode: ProfileMode) -> Single<Result<WorkerProfileVO, DomainError>>

    // 요양보호사 프로필 업데이트
    func updateWorkerProfile(stateObject: WorkerProfileStateObject) -> Single<Result<Void, DomainError>>
}
