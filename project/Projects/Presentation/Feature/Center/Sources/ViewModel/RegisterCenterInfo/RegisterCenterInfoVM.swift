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
    public var imageAndIntroductionValidation: Driver<Bool>? = nil
    public var profileRegisterSuccess: Driver<Void>? = nil
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
        
        let imageValidation = editingCenterImage
            .map { [unowned self] image in
                validateSelectedImage(image: image)
            }
            .share()
        
        let imageValidationSuccess = imageValidation
            .compactMap { $0 }
        
        let imageValidationFailure = imageValidation
            .filter { $0 == nil }
            .map { _ in
                DefaultAlertContentVO(
                    title: "이미지 업로드 실패",
                    message: "지원하지 않는 파일 형식"
                )
            }
        
        self.imageAndIntroductionValidation = Observable
            .combineLatest(
                editingCenterIntroduction,
                imageValidationSuccess
            )
            .map { [stateObject] (intro, imageInfo) in
                
                printIfDebug("\(#function) 입력중인 센터소개: \(intro)")
                
                stateObject.introduce = intro
                stateObject.imageInfo = imageInfo
                
                return !intro.isEmpty
            }
            .asDriver(onErrorJustReturn: false)
        
        let profileRegisterResult = self.completeButtonPressed
            .flatMap { [useCase, stateObject] _ in
#if DEBUG
                return Single<Result<Void, UserInfoError>>.just(.success(()))
#endif
                return useCase.registerCenterProfile(state: stateObject)
            }
        
        profileRegisterSuccess = profileRegisterResult
            .compactMap { $0.value }
            .asDriver(onErrorJustReturn: ())
            
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
