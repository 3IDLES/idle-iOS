//
//  UserProfileRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/20/24.
//

import Foundation


import RxSwift

public protocol UserProfileRepository: RepositoryBase {
    
    func registerCenterProfileForText(state: CenterProfileRegisterState) -> Single<Void>
    
    func getCenterProfile(mode: ProfileMode) -> Single<CenterProfileVO>
    func updateCenterProfileForText(phoneNumber: String, introduction: String?) -> Single<Void>
    
    // ImageUpload
    func uploadImage(_ userType: UserType, imageInfo: ImageUploadInfo) -> Single<Void>
    
    func getWorkerProfile(mode: ProfileMode) -> Single<WorkerProfileVO>
    func updateWorkerProfile(stateObject: WorkerProfileStateObject) -> Single<Void>
}
