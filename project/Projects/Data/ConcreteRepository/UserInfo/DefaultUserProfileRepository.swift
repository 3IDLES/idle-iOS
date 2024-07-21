//
//  DefaultUserProfileRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity
import RepositoryInterface
import NetworkDataSource

public class DefaultUserProfileRepository: UserProfileRepository {
    
    let userInformationService: UserInformationService
    let externalRequestService: ExternalRequestService
    
    public init(_ keyValueStore: KeyValueStore? = nil) {
        
        if let keyValueStore {
            self.userInformationService = .init(keyValueStore: keyValueStore)
            self.externalRequestService = .init(keyValueStore: keyValueStore)
        } else {
            self.userInformationService = .init()
            self.externalRequestService = .init()
        }
    }
    
    public func getCenterProfile() -> Single<CenterProfileVO> {
        
        userInformationService
            .requestDecodable(api: .getCenterProfile, with: .withToken)
            .map { (dto: CenterProfileDTO) in dto.toEntity() }
    }
    
    public func updateCenterProfileForText(phoneNumber: String, introduction: String?) -> Single<Void> {
        userInformationService
            .request(api: .updateCenterProfile(
                officeNumber: phoneNumber,
                introduce: introduction
            ), with: .withToken)
            .map { _ in return () }
    }
    
    /// 이미지 업로드
    public func uploadImage(_ userType: UserType, imageInfo: ImageUploadInfo) -> Single<Void> {
        
        getPreSignedUrl(userType, ext: imageInfo.ext)
            .flatMap { [unowned self] dto in
                self.uploadImageToPreSignedUrl(url: dto.uploadUrl, data: imageInfo.data)
                    .map { _ in (id: dto.imageId, ext: dto.imageFileExtension) }
            }
            .flatMap { (id, ext) in
                self.callbackToServerForUploadImageSuccess(userType, imageId: id, ext: ext)
            }
    }
    
    private func getPreSignedUrl(_ userType: UserType, ext: String) -> Single<ProfileImageUploadInfoDTO> {
        userInformationService
            .request(api: .getPreSignedUrl(userType: userType, imageExt: ext), with: .withToken)
            .map(ProfileImageUploadInfoDTO.self)
    }
    
    private func uploadImageToPreSignedUrl(url: String, data: Data) -> Single<Void> {
        externalRequestService
            .request(api: .uploadImageToS3(url: url, data: data), with: .plain)
            .map { _ in () }
    }
    
    private func callbackToServerForUploadImageSuccess(_ userType: UserType, imageId: String, ext: String) -> Single<Void> {
        userInformationService
            .request(api: .imageUploadSuccessCallback(
                userType: userType,
                imageId: imageId,
                imageExt: ext), with: .withToken
            )
            .map { _ in () }
    }
}
