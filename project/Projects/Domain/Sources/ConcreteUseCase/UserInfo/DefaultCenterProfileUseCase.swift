//
//  DefaultCenterProfileUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 7/20/24.
//

import Foundation


import RxSwift

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
    
    public func getFreshProfile(mode: ProfileMode) -> RxSwift.Single<Result<CenterProfileVO, DomainError>> {
        userProfileRepository.getCenterProfile(mode: mode)
    }
    
    public func updateProfile(phoneNumber: String?, introduction: String?, imageInfo: ImageUploadInfo?) -> Single<Result<Void, DomainError>> {
        
        var updateTextTask: Observable<Result<Void, DomainError>>!
        var updateImageTask: Observable<Result<Void, DomainError>>!
        
        if let phoneNumber {
            updateTextTask = userProfileRepository.updateCenterProfileForText(
                phoneNumber: phoneNumber,
                introduction: introduction
            )
            .asObservable()
            .share()
        } else {
            updateTextTask = .just(.success(()))
        }
        
        if let imageInfo {
            updateImageTask = userProfileRepository.uploadImage(
                .center,
                imageInfo: imageInfo
            )
            .asObservable()
            .share()
        } else {
            updateImageTask = .just(.success(()))
        }
        
        let textSuccess = updateTextTask.compactMap { $0.value }
        let textFailure = updateTextTask.compactMap { $0.error }
        
        let imageSuccess = updateImageTask.compactMap { $0.value }
        let imageFailure = updateImageTask.compactMap { $0.error }
        
        let fetchProfileResult = Observable
            .zip(
                textSuccess.asObservable(),
                imageSuccess.asObservable()
            )
            .flatMap { [userProfileRepository] _ in
                // 등록성공후 내프로필 불러오기
                userProfileRepository.getCenterProfile(mode: .myProfile)
            }
            .share()
        
        let task = fetchProfileResult
            .map { [userInfoLocalRepository] result -> Result<Void, DomainError> in
                switch result {
                case .success(let vo):
                    userInfoLocalRepository.updateCurrentCenterData(vo: vo)
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            }
        
        let failures = Observable
            .merge(
                textFailure.asObservable(),
                imageFailure.asObservable()
            )
            .map { error -> Result<Void, DomainError> in
                .failure(error)
            }
            
        return Observable.merge(
            task.asObservable(),
            failures
        )
        .asSingle()
    }
    
    public func registerCenterProfile(state: CenterProfileRegisterState) -> Single<Result<Void, DomainError>> {
        
        var registerImageTask: Observable<Result<Void, DomainError>>!
        
        let imageInfo = state.imageInfo
        
        if let imageInfo {
            registerImageTask = userProfileRepository.uploadImage(
                .center,
                imageInfo: imageInfo
            )
            .asObservable()
            .share()
        } else {
            registerImageTask = .just(.success(()))
        }
        
        let registerImageTaskSuccess = registerImageTask.compactMap { $0.value }
        let registerImageTaskFailure = registerImageTask.compactMap { $0.error }
        
        let registerTextTask = userProfileRepository
            .registerCenterProfileForText(state: state)
            .asObservable()
            .share()
        let registerTextTaskSuccess = registerTextTask.compactMap { $0.value }
        let registerTextTaskFailure = registerTextTask.compactMap { $0.error }
        
        let fetchProfileResult = Observable
            .zip(
                registerImageTaskSuccess.asObservable(),
                registerTextTaskSuccess.asObservable()
            )
            .flatMap { [userProfileRepository] _ in
                // 등록성공후 내프로필 불러오기
                userProfileRepository.getCenterProfile(mode: .myProfile)
            }
            .share()
        
        let task = fetchProfileResult
            .map { [userInfoLocalRepository] result -> Result<Void, DomainError> in
                switch result {
                case .success(let vo):
                    userInfoLocalRepository.updateCurrentCenterData(vo: vo)
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            }
        
        let failures = Observable
            .merge(
                registerImageTaskFailure.asObservable(),
                registerTextTaskFailure.asObservable()
            )
            .map { error -> Result<Void, DomainError> in
                .failure(error)
            }
        
        return Observable.merge(
            task.asObservable(),
            failures
        )
        .asSingle()
    }
}
