//
//  UserProfileRepository.swift
//  RepositoryInterface
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity

public protocol UserProfileRepository: RepositoryBase {
    
    func getCenterProfile() -> Single<CenterProfileVO>
    func updateCenterProfileForText(phoneNumber: String, introduction: String?) -> Single<Void>
    
    // ImageUpload
    func uploadImage(_ userType: UserType, imageInfo: ImageUploadInfo) -> Single<Void>
}
