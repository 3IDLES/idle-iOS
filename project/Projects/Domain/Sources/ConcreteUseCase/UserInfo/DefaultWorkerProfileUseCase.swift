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
        convert(task: userProfileRepository.getWorkerProfile(mode: mode))
    }
    
    public func updateProfile(stateObject: WorkerProfileStateObject, imageInfo: ImageUploadInfo?) -> Single<Result<Void, DomainError>> {

        var updateTextTask: Single<Void>!
        var updateImageTask: Single<Void>!
        
        updateTextTask = userProfileRepository.updateWorkerProfile(
            stateObject: stateObject
        )
        
        if let imageInfo {
            updateImageTask = userProfileRepository.uploadImage(
                .worker,
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
                userProfileRepository.getWorkerProfile(mode: .myProfile)
            }
            .map({ [userInfoLocalRepository] vo in
                userInfoLocalRepository.updateCurrentWorkerData(vo: vo)
            })
            .asSingle()
        
        return convert(task: task)
    }
}
