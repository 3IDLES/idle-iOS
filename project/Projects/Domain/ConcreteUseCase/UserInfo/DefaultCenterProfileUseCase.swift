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
    
    let repository: UserProfileRepository
    
    public init(repository: UserProfileRepository) {
        self.repository = repository
    }
    
    public func getProfile() -> Single<Result<CenterProfileVO, UserInfoError>> {
        convert(task: repository
            .getCenterProfile()) { [unowned self] error in
                toDomainError(error: error)
            }
    }
    
    public func updateProfile(phoneNumber: String?, introduction: String?, imageInfo: ImageUploadInfo?) -> Single<Result<Void, UserInfoError>> {

        var updateText: Single<Void>!
        var updateImage: Single<Void>!
        
        if let phoneNumber {
            updateText = repository.updateCenterProfileForText(
                phoneNumber: phoneNumber,
                introduction: introduction
            )
        } else {
            updateText = .just(())
        }
        
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
          
        let updateImageResult = updateImage
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
                updateImageResult.asObservable()
            )
            .map { _ in () }
            .asSingle()
        
        return convert(task: task) { [unowned self] error in
            toDomainError(error: error)
        }
    }
}
