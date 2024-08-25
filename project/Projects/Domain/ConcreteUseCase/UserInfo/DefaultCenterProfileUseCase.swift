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
    
    public func getProfile(mode: ProfileMode) -> Single<Result<CenterProfileVO, DomainError>> {
        convert(task: repository.getCenterProfile(mode: mode))
    }
    
    public func updateProfile(phoneNumber: String?, introduction: String?, imageInfo: ImageUploadInfo?) -> Single<Result<Void, DomainError>> {
        
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
        
        return convert(task: task)
    }
    
    public func registerCenterProfile(state: CenterProfileRegisterState) -> Single<Result<Void, DomainError>> {
        
        var registerImage: Single<Void>!
        
        let imageInfo = state.imageInfo
        
        if let imageInfo {
            registerImage = repository.uploadImage(
                .center,
                imageInfo: imageInfo
            )
        } else {
            registerImage = .just(())
        }
        
        let registerTextResult = repository.registerCenterProfileForText(state: state)
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
          
        let uploadImageResult = registerImage
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
                registerTextResult.asObservable(),
                uploadImageResult.asObservable()
            )
            .map { _ in () }
            .asSingle()
        
        return convert(task: task)
    }
}
