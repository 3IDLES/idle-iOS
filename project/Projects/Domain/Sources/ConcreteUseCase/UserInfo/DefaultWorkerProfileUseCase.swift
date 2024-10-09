//
//  DefaultWorkerProfileUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/10/24.
//

import Foundation


import RxSwift

public class DefaultWorkerProfileUseCase: WorkerProfileUseCase {
    
    let userProfileRepository: UserProfileRepository
    let userInfoLocalRepository: UserInfoLocalRepository
    
    public init(userProfileRepository: UserProfileRepository, userInfoLocalRepository: UserInfoLocalRepository) {
        self.userProfileRepository = userProfileRepository
        self.userInfoLocalRepository = userInfoLocalRepository
    }
    
    public func getProfile(mode: ProfileMode) -> Single<Result<WorkerProfileVO, DomainError>> {
        
        if let cachedProfile = userInfoLocalRepository.getCurrentWorkerData() {
            // Cache된 정보가 있는 경우 해당 값을 전달
            return .just(.success(cachedProfile))
        }
        
        return getFreshProfile(mode: mode)
    }
    
    public func getFreshProfile(mode: ProfileMode) -> RxSwift.Single<Result<WorkerProfileVO, DomainError>> {
        userProfileRepository.getWorkerProfile(mode: mode)
    }
    
    public func updateProfile(stateObject: WorkerProfileStateObject, imageInfo: ImageUploadInfo?) -> Single<Result<Void, DomainError>> {

        var updateTextTask: Observable<Result<Void, DomainError>>!
        var updateImageTask: Observable<Result<Void, DomainError>>!
        
        updateTextTask = userProfileRepository.updateWorkerProfile(stateObject: stateObject)
            .asObservable()
            .share()
        
        if let imageInfo {
            updateImageTask = userProfileRepository.uploadImage(
                .worker,
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
                userProfileRepository.getWorkerProfile(mode: .myProfile)
            }
            .share()
        
        let task = fetchProfileResult
            .map { [userInfoLocalRepository] result -> Result<Void, DomainError> in
                switch result {
                case .success(let vo):
                    userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
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
}
