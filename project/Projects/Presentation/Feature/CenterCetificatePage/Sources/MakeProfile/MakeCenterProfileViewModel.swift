//
//  RegisterCenterInfoVM.swift
//  WaitCertificatePageCoordinator
//
//  Created by choijunios on 7/26/24.
//

import UIKit
import Domain
import PresentationCore
import BaseFeature
import Core


import RxCocoa
import RxSwift


class MakeCenterProfileViewModel: BaseViewModel, MakeCenterProfileVMable {

    // Navigation
    var presentOverviewPage: ((CenterProfileRegisterState) -> ())?
    var changeToAuthFlow: (() -> ())?
    
    // Input
    var backButtonClicked: PublishRelay<Void> = .init()
    var editingName: PublishRelay<String> = .init()
    var editingCenterNumber: PublishRelay<String> = .init()
    var editingAddress: PublishRelay<AddressInformation> = .init()
    var editingDetailAddress: PublishRelay<String> = .init()
    var editingCenterIntroduction: PublishRelay<String> = .init()
    var editingCenterImage: PublishRelay<UIImage> = .init()
    var completeButtonPressed: PublishRelay<Void> = .init()
    
    // Output
    var nameAndNumberValidation: Driver<Bool>? = nil
    var addressValidation: Driver<Bool>? = nil
    var introductionValidation: Driver<Bool>? = nil
    var imageValidation: Driver<UIImage>? = nil
    
    // StatObject
    private let stateObject = CenterProfileRegisterState()

    override init() {
        super.init()
        
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
        
        self.completeButtonPressed
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                obj.presentOverviewPage?(obj.stateObject)
            })
            .disposed(by: disposeBag)
        
        backButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                obj.changeToAuthFlow?()
            })
            .disposed(by: disposeBag)
        
        // Alert
        Observable
            .merge(
                imageValidationFailure
            )
            .subscribe(onNext: { [weak self] alertVO in
                
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
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
