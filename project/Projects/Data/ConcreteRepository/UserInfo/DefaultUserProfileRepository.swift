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
    
    /// 센터프로필(최초 센터정보)를 등록합니다.
    public func registerCenterProfileForText(state: CenterProfileRegisterState) -> Single<Void> {
        
        let dto = RegisterCenterProfileDTO(
            centerName: state.centerName,
            officeNumber: state.officeNumber,
            roadNameAddress: state.roadNameAddress,
            lotNumberAddress: state.lotNumberAddress,
            detailedAddress: state.detailedAddress,
            introduce: state.introduce
        )
        let data = try! JSONEncoder().encode(dto)
        
        return userInformationService
            .request(api: .registerCenterProfile(data: data), with: .withToken)
            .map { _ in () }
    }
    
    public func getCenterProfile(mode: ProfileMode) -> Single<CenterProfileVO> {
        
        var api: UserInformationAPI!
        
        switch mode {
        case .myProfile:
            api = .getCenterProfile
        case .otherProfile(let id):
            api = .getOtherCenterProfile(id: id)
        }
        
        return userInformationService
            .requestDecodable(api: api, with: .withToken)
            .map { (dto: CenterProfileDTO) in dto.toEntity() }
    }
    
    public func getCenterProfile(id: String) -> Single<CenterProfileVO> {
        userInformationService
            .requestDecodable(api: .getOtherCenterProfile(id: id), with: .withToken)
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
