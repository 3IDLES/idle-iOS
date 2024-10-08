//
//  DefaultUserProfileRepository.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import Domain
import DataSource


import RxSwift

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
    public func registerCenterProfileForText(state: CenterProfileRegisterState) -> Single<Result<Void, DomainError>> {
        
        let dto = RegisterCenterProfileDTO(
            centerName: state.centerName,
            officeNumber: state.officeNumber,
            roadNameAddress: state.roadNameAddress,
            lotNumberAddress: state.lotNumberAddress,
            detailedAddress: state.detailedAddress,
            introduce: state.introduce
        )
        let data = try! JSONEncoder().encode(dto)
        
        let dataTask = userInformationService
            .request(api: .registerCenterProfile(data: data), with: .withToken)
            .map { _ in () }
        
        return convertToDomain(task: dataTask)
    }
    
    public func getCenterProfile(mode: ProfileMode) -> Single<Result<CenterProfileVO, DomainError>> {
        
        var api: UserInformationAPI!
        
        switch mode {
        case .myProfile:
            api = .getMyCenterProfile
        case .otherProfile(let id):
            api = .getCenterProfile(id: id)
        }
        
        let dataTask = userInformationService
            .requestDecodable(api: api, with: .withToken)
            .map { (dto: CenterProfileDTO) in dto.toEntity() }
        
        return convertToDomain(task: dataTask)
    }
    
    public func getCenterProfile(id: String) -> Single<Result<CenterProfileVO, DomainError>> {
        let dataTask = userInformationService
            .requestDecodable(api: .getCenterProfile(id: id), with: .withToken)
            .map { (dto: CenterProfileDTO) in dto.toEntity() }
        
        return convertToDomain(task: dataTask)
    }
    
    public func updateCenterProfileForText(phoneNumber: String, introduction: String?) -> Single<Result<Void, DomainError>> {
        let dataTask = userInformationService
            .request(api: .updateCenterProfile(
                officeNumber: phoneNumber,
                introduce: introduction
            ), with: .withToken)
            .map { _ in return () }
        
        return convertToDomain(task: dataTask)
    }
    
    /// 요양보호사 프로필 정보를 가져옵니다.
    public func getWorkerProfile(mode: ProfileMode) -> Single<Result<WorkerProfileVO, DomainError>> {
        var api: UserInformationAPI!
        
        switch mode {
        case .myProfile:
            api = .getMyWorkerProfile
        case .otherProfile(let id):
            api = .getOtherWorkerProfile(id: id)
        }
        
        let dataTask = userInformationService
            .requestDecodable(api: api, with: .withToken)
            .map { (dto: CarerProfileDTO) in dto.toVO() }
        
        return convertToDomain(task: dataTask)
    }
    
    /// 요양보호사 프로필 정보를 업데이트 합니다.
    public func updateWorkerProfile(stateObject: WorkerProfileStateObject) -> Single<Result<Void, DomainError>> {
        
        var availableValues: [String: Any] = [:]
        
        if let experienceYear = stateObject.experienceYear {
            availableValues["experienceYear"] = experienceYear
        }

        if let roadNameAddress = stateObject.roadNameAddress {
            availableValues["roadNameAddress"] = roadNameAddress
        }

        if let lotNumberAddress = stateObject.lotNumberAddress {
            availableValues["lotNumberAddress"] = lotNumberAddress
        }

        if let introduce = stateObject.introduce {
            availableValues["introduce"] = introduce
        }

        if let speciality = stateObject.speciality {
            availableValues["speciality"] = speciality
        }

        if let isJobFinding = stateObject.isJobFinding {
            availableValues["jobSearchStatus"] = isJobFinding ? "YES" : "NO"
        }
        
        let encoded = try! JSONSerialization.data(withJSONObject: availableValues)
        
        let dataTask = userInformationService
            .request(api: .updateWorkerProfile(data: encoded), with: .withToken)
            .map { _ in return () }
        
        return convertToDomain(task: dataTask)
    }
    
    /// 이미지 업로드
    public func uploadImage(_ userType: UserType, imageInfo: ImageUploadInfo) -> Single<Result<Void, DomainError>> {
        
        let getPreSignedUrlResult = getPreSignedUrl(userType, ext: imageInfo.ext)
        
        let getPreSignedUrlSuccess = getPreSignedUrlResult.compactMap { $0.value }
        let getPreSignedUrlFailure = getPreSignedUrlResult.compactMap { $0.error }
        
        let uploadImageToPreSignedUrlResult = getPreSignedUrlSuccess
            .asObservable()
            .unretained(self)
            .flatMap { (obj, dto) in
                obj
                    .uploadImageToPreSignedUrl(url: dto.uploadUrl, data: imageInfo.data)
                    .map { result -> Result<ProfileImageUploadInfoDTO, DomainError> in
                        switch result {
                        case .success:
                            return .success(dto)
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
            }
        
        let uploadImageToPreSignedUrlSuccess = uploadImageToPreSignedUrlResult.compactMap { $0.value }
        let uploadImageToPreSignedUrlFailure = uploadImageToPreSignedUrlResult.compactMap { $0.error }
            
        let callbackToServerForUploadImageResult = uploadImageToPreSignedUrlSuccess
            .unretained(self)
            .flatMap { (obj, dto) in
                obj.callbackToServerForUploadImageSuccess(
                    userType,
                    imageId: dto.imageId,
                    ext: dto.imageFileExtension
                )
            }
        
        return Observable<Result<Void, DomainError>>
            .merge(
                callbackToServerForUploadImageResult,
                Observable.merge(
                    getPreSignedUrlFailure.asObservable(),
                    uploadImageToPreSignedUrlFailure.asObservable()
                ).map { error in Result<Void, DomainError>.failure(error) }
            )
            .asSingle()
        
    }
    
    private func getPreSignedUrl(_ userType: UserType, ext: String) -> Single<Result<ProfileImageUploadInfoDTO, DomainError>> {
        let dataTask = userInformationService
            .request(api: .getPreSignedUrl(userType: userType, imageExt: ext), with: .withToken)
            .map(ProfileImageUploadInfoDTO.self)
        
        return convertToDomain(task: dataTask)
    }
    
    private func uploadImageToPreSignedUrl(url: String, data: Data) -> Single<Result<Void, DomainError>> {
        let dataTask = externalRequestService
            .request(api: .uploadImageToS3(url: url, data: data), with: .plain)
            .map { _ in () }
        
        return convertToDomain(task: dataTask)
    }
    
    private func callbackToServerForUploadImageSuccess(_ userType: UserType, imageId: String, ext: String) -> Single<Result<Void, DomainError>> {
        let dataTask = userInformationService
            .request(api: .imageUploadSuccessCallback(
                userType: userType,
                imageId: imageId,
                imageExt: ext), with: .withToken
            )
            .map { _ in () }
        
        return convertToDomain(task: dataTask)
    }
}
