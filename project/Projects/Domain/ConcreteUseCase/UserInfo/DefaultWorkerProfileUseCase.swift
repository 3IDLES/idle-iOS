//
//  DefaultWorkerProfileUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 8/10/24.
//

import Foundation
import RxSwift
import Entity
import UseCaseInterface
import RepositoryInterface

public class DefaultWorkerProfileUseCase: WorkerProfileUseCase {
    
    let repository: UserProfileRepository
    
    public init(repository: UserProfileRepository) {
        self.repository = repository
    }
    
    public func getProfile(mode: ProfileMode) -> Single<Result<WorkerProfileVO, UserInfoError>> {
        convert(task: repository.getWorkerProfile(mode: mode)) { [unowned self] error in
            toDomainError(error: error)
        }
    }
    
    public func updateProfile(stateObject: WorkerProfileStateObject, imageInfo: ImageUploadInfo?) -> Single<Result<Void, UserInfoError>> {

        var updateText: Single<Void>!
        var updateImage: Single<Void>!
        
        updateText = repository.updateWorkerProfile(
            stateObject: stateObject
        )
        
        if let imageInfo {
            updateImage = repository.uploadImage(
                .center,
                imageInfo: imageInfo
            )
        } else {
            updateImage = .just(())
        }
        
        let updateTextResult = updateText
            .catch { error in
                if let httpExp = error as? HTTPResponseException {
                    let newError = HTTPResponseException(
                        status: httpExp.status,
                        rawCode: "Err-001",
                        timeStamp: httpExp.timeStamp
                    )
                    
                    return .error(newError)
                }
                return .error(error)
            }
          
        let uploadImageResult = updateImage
            .catch { error in
                if let httpExp = error as? HTTPResponseException {
                    let newError = HTTPResponseException(
                        status: httpExp.status,
                        rawCode: "Err-002",
                        timeStamp: httpExp.timeStamp
                    )
                    
                    return .error(newError)
                }
                return .error(error)
            }
        
        let task = Observable
            .zip(
                updateTextResult.asObservable(),
                uploadImageResult.asObservable()
            )
            .map { _ in () }
            .asSingle()
        
        return convert(task: task) { [unowned self] error in
            toDomainError(error: error)
        }
    }
}
