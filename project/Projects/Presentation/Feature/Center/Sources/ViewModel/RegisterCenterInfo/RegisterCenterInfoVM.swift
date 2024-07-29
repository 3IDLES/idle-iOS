//
//  RegisterCenterInfoVM.swift
//  AuthFeature
//
//  Created by choijunios on 7/26/24.
//

import UIKit
import RxCocoa
import RxSwift
import Entity
import PresentationCore
import UseCaseInterface

public class RegisterCenterInfoVM: RegisterCenterInfoViewModelable {
    
    // Input
    public var editingName: PublishRelay<String> = .init()
    public var editingCenterNumber: PublishRelay<String> = .init()
    public var editingAddress: PublishRelay<AddressInformation> = .init()
    public var editingDetailAddress: PublishRelay<String> = .init()
    public var editingCenterIntroduction: PublishRelay<String> = .init()
    public var editingCenterImage: PublishRelay<UIImage> = .init()
    public var completeButtonPressed: PublishRelay<Void> = .init()
    
    // Output
    public var nameAndNumberValidation: Driver<Bool>? = nil
    public var addressValidation: Driver<Bool>? = nil
    public var introductionValidation: Driver<Bool>? = nil
    public var imageValidation: Driver<UIImage>? = nil
    public var profileRegisterSuccess: Driver<CenterProfileCardVO>? = nil
    public var alert: Driver<DefaultAlertContentVO>? = nil
    
    // StatObject
    private let stateObject = CenterProfileRegisterState()

    public init(profileUseCase useCase: CenterProfileUseCase) {
        
        // Set stream
        self.nameAndNumberValidation = Observable
            .combineLatest(
                editingName,
                editingCenterNumber
            )
            .map { [stateObject] (name, phoneNumber) in
                
                printIfDebug("\(#function) 입력중인 센터이름: \(name)")
                printIfDebug("\(#function) 입력중인 센터번호: \(phoneNumber)")
                
                stateObject.centerName = name
                stateObject.officeNumber = phoneNumber
                
                return !name.isEmpty && !phoneNumber.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        self.addressValidation = Observable
            .combineLatest(
                editingAddress,
                editingDetailAddress
            )
            .map { [stateObject] (addressInfo, detailAd) in
                
                printIfDebug("\(#function) 입력중인 도려명 주소: \(addressInfo.roadAddress) \n 지번: \(addressInfo.jibunAddress)")
                printIfDebug("\(#function) 입력중인 주소 디테일: \(detailAd)")
                
                let road = addressInfo.roadAddress
                let jibun = addressInfo.jibunAddress
                stateObject.roadNameAddress = road
                stateObject.lotNumberAddress = jibun
                stateObject.detailedAddress = detailAd
                
                return !road.isEmpty && !jibun.isEmpty && !detailAd.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        // 소개글은 필수값임 아님으로 별도로 조건 수행X
        self.introductionValidation = editingCenterIntroduction
            .map { [stateObject] intro in
                stateObject.introduce = intro
                return true
            }
            .asDriver(onErrorJustReturn: false)
        
        let imageValidation = editingCenterImage
            .map { [unowned self] image in
                let info = validateSelectedImage(image: image)
                return (image: image, info: info)
            }
            .share()
        
        let imageValidationSuccess = imageValidation
            .compactMap { (image, info) -> (UIImage, ImageUploadInfo)? in
                if let info { return (image, info) }
                return nil
            }
        
        let imageValidationFailure = imageValidation
            .filter { $0.info == nil }
            .map { _ in
                DefaultAlertContentVO(
                    title: "이미지 업로드 실패",
                    message: "지원하지 않는 파일 형식"
                )
            }
        
        self.imageValidation = imageValidationSuccess
            .map { [stateObject] (image, info) in
                printIfDebug("\(#function) 입력중인 센터소개")
                stateObject.imageInfo = info
                return image
            }
            .asDriver(onErrorJustReturn: .init())
        
        let profileRegisterResult = self.completeButtonPressed
            .flatMap { [useCase, stateObject] _ in
#if DEBUG
                return Single<Result<Void, UserInfoError>>.just(.success(()))
#endif
                return useCase.registerCenterProfile(state: stateObject)
            }
        
        profileRegisterSuccess = profileRegisterResult
            .compactMap { $0.value }
            .map { [stateObject] in
                let cardVO = CenterProfileCardVO(
                    name: stateObject.centerName,
                    location: stateObject.roadNameAddress
                )
                return cardVO
            }
            .asDriver(onErrorJustReturn: .default)
            
        let profileRegisterFailure = profileRegisterResult
            .compactMap { $0.error }
            .map { error in
                DefaultAlertContentVO(
                    title: "센터정보 등록 싶패",
                    message: error.message
                )
            }
        
        // Alert
        self.alert = Observable
            .merge(
                imageValidationFailure,
                profileRegisterFailure
            )
            .asDriver(onErrorJustReturn: .default)
    }
    
    func validateSelectedImage(image: UIImage) -> ImageUploadInfo? {
        if let pngData = image.pngData() {
            return .init(data: pngData, ext: "PNG")
        } else if let jpegData = image.jpegData(compressionQuality: 1) {
            return .init(data: jpegData, ext: "JPEG")
        }
        return nil
    }
}
