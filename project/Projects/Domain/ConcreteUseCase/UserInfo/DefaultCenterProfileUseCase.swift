//
//  DefaultCenterProfileUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/20/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefaultCenterProfileUseCase: CenterProfileUseCase {
    
    let userProfileRepository: UserProfileRepository
    let userInfoLocalRepository: UserInfoLocalRepository
    
    public init(userProfileRepository: UserProfileRepository, userInfoLocalRepository: UserInfoLocalRepository) {
        self.userProfileRepository = userProfileRepository
        self.userInfoLocalRepository = userInfoLocalRepository
    }
    
    public func getProfile(mode: ProfileMode) -> Single<Result<CenterProfileVO, DomainError>> {
        
        if let cachedProfile = userInfoLocalRepository.getCurrentCenterData() {
            // 캐쉬된 데이터 전송
            return .just(.success(cachedProfile))
        }
        
        return getFreshProfile(mode: mode)
    }
    
    public func getFreshProfile(mode: Entity.ProfileMode) -> RxSwift.Single<Result<Entity.CenterProfileVO, Entity.DomainError>> {
        convert(task: userProfileRepository.getCenterProfile(mode: mode))
    }
    
    public func updateProfile(phoneNumber: String?, introduction: String?, imageInfo: ImageUploadInfo?) -> Single<Result<Void, DomainError>> {
        
        var updateTextTask: Single<Void>!
        var updateImageTask: Single<Void>!
        
        if let phoneNumber {
            updateTextTask = userProfileRepository.updateCenterProfileForText(
                phoneNumber: phoneNumber,
                introduction: introduction
            )
        } else {
            updateTextTask = .just(())
        }
        
        if let imageInfo {
            updateImageTask = userProfileRepository.uploadImage(
                .center,
                imageInfo: imageInfo
            )
        } else {
            updateImageTask = .just(())
        }
        
        let task = Observable
            .zip(
                updateTextTask.asObservable(),
                updateImageTask.asObservable()
            )
            .flatMap { [userProfileRepository] _ in
                // 등록성공후 내프로필 불러오기
                userProfileRepository.getCenterProfile(mode: .myProfile)
            }
            .map({ [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateCurrentCenterData(vo: vo)
            })
            .asSingle()
        
        return convert(task: task)
    }
    
    public func registerCenterProfile(state: CenterProfileRegisterState) -> Single<Result<Void, DomainError>> {
        
        var registerImageTask: Single<Void>!
        
        let imageInfo = state.imageInfo
        
        if let imageInfo {
            registerImageTask = userProfileRepository.uploadImage(
                .center,
                imageInfo: imageInfo
            )
        } else {
            registerImageTask = .just(())
        }
        
        let registerTextTask = userProfileRepository.registerCenterProfileForText(state: state)
          
        let task = Observable
            .zip(
                registerTextTask.asObservable(),
                registerImageTask.asObservable()
            )
            .flatMap { [userProfileRepository] _ in
                // 등록성공후 내프로필 불러오기
                userProfileRepository.getCenterProfile(mode: .myProfile)
            }
            .map({ [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateCurrentCenterData(vo: vo)
            })
            .asSingle()
        
        return convert(task: task)
    }
}
