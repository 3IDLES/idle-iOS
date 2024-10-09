//
//  CenterProfileViewModel.swift
//  CenterFeature
//
//  Created by choijunios on 7/18/24.
//

import UIKit
import PresentationCore
import Repository
import BaseFeature
import Domain
import Core


import RxSwift
import RxCocoa
import SDWebImageWebPCoder

struct ChangeCenterInformation {
    let phoneNumber: String?
    let introduction: String?
    let image: UIImage?
}

protocol CenterProfileViewModelable: BaseViewModel, CenterProfileInputable & CenterProfileOutputable {
    var mode: ProfileMode { get }
}

protocol CenterProfileInputable {
    var readyToFetch: PublishRelay<Void> { get }
    var editingButtonPressed: PublishRelay<Void> { get }
    var editingFinishButtonPressed: PublishRelay<Void> { get }
    var editingPhoneNumber: BehaviorRelay<String> { get }
    var editingInstruction: BehaviorRelay<String> { get }
    var selectedImage: BehaviorRelay<UIImage?> { get }
    
    var exitButtonClicked: PublishRelay<Void> { get }
}

protocol CenterProfileOutputable {
    var navigationBarTitle: String { get }
    var centerName: Driver<String>? { get }
    var centerLocation: Driver<String>? { get }
    var centerPhoneNumber: Driver<String>? { get }
    var centerIntroduction: Driver<String>? { get }
    var displayingImage: Driver<UIImage?>? { get }
    var isEditingMode: Driver<Bool>? { get }
    var editingValidation: Driver<Void>? { get }
}


class CenterProfileViewModel: BaseViewModel, CenterProfileViewModelable {
    
    // Init
    let mode: ProfileMode
    
    // Injected
    @Injected var cacheRepository: CacheRepository
    @Injected var profileUseCase: CenterProfileUseCase
    
    // Navigation
    var exitPage: (() -> ())?
    
    private var fetchedPhoneNumber: String?
    private var fetchedIntroduction: String?
    private var fetchedImage: UIImage?
    
    private var editingImageInfo: ImageUploadInfo?
    
    var readyToFetch: PublishRelay<Void> = .init()
    var editingButtonPressed: PublishRelay<Void> = .init()
    var editingFinishButtonPressed: PublishRelay<Void> = .init()
    var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
    var editingInstruction: BehaviorRelay<String> = .init(value: "")
    var selectedImage: BehaviorRelay<UIImage?> = .init(value: nil)
    var exitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    // 기본 데이터
    let navigationBarTitle: String
    var centerName: Driver<String>?
    var centerLocation: Driver<String>?
    var centerPhoneNumber: Driver<String>?
    var centerIntroduction: Driver<String>?
    var displayingImage: Driver<UIImage?>?
    
    var originalPhonenumber: String = ""
    
    // 수정 상태 여부
    var isEditingMode: Driver<Bool>?
    
    // 요구사항 X
    var editingValidation: Driver<Void>?
    
    // Image
    private let imageDownLoadScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    init(mode: ProfileMode) {
        
        self.mode = mode
        
        let navigationBarTitle = (mode == .myProfile ? "내 센터 정보" : "센터 정보")
        self.navigationBarTitle = navigationBarTitle
        
        super.init()
        
        // MARK: fetch from server
        let profileRequestResult = mapEndLoading(mapStartLoading(readyToFetch)
            .unretained(self)
            .flatMap { (obj, _) in
                obj.profileUseCase.getProfile(mode: obj.mode)
            })
            .share()
        
        let profileRequestSuccess = profileRequestResult
            .compactMap { $0.value }
            .share()
        
        let profileRequestFailureAlert = profileRequestResult
            .compactMap { $0.error }
            .map { error in
                DefaultAlertContentVO(
                    title: "프로필 정보 불러오기 실패",
                    message: error.message
                )
            }
            
        let centerNameDriver = profileRequestSuccess
            .map { $0.centerName }
            .asDriver(onErrorJustReturn: "")

        let centerAddressDriver = profileRequestSuccess
            .map { $0.roadNameAddress }
            .asDriver(onErrorJustReturn: "")
        
        // 센터 소개는 필수값이 아님, 공백일 경우 필터링
        let centerIntroductionDriver = profileRequestSuccess
            .map { [weak self] in
                let introduce = $0.introduce
                self?.fetchedIntroduction = introduce
                return introduce
            }
            .asDriver(onErrorJustReturn: "")
    
        let centerPhoneNumberDriver = profileRequestSuccess
            .map { [weak self] in
                let phoneNumber = $0.officeNumber
                self?.fetchedPhoneNumber = phoneNumber
                self?.originalPhonenumber = phoneNumber
                return phoneNumber
            }
            .asDriver(onErrorJustReturn: "")
        
        let fetchCenterImageInfo = mapEndLoading(mapStartLoading(profileRequestSuccess)
            .compactMap { $0.profileImageInfo }
            .observe(on: imageDownLoadScheduler)
            .flatMap { [cacheRepository] downloadInfo in
                cacheRepository
                    .getImage(imageInfo: downloadInfo)
            }.map { image -> UIImage? in image })
        
        // MARK: image validation
        let displayingImageDriver = Observable
            .merge(
                fetchCenterImageInfo,
                selectedImage.compactMap { $0 }
            )
            .asDriver(onErrorJustReturn: .init())
        
        
        // 최신 값들 + 버튼이 눌릴 경우 변경 로직이 실행된다.
        let checkImageSelectionResult = mapStartLoading(editingFinishButtonPressed)
            .withLatestFrom(selectedImage)
            .share()
        
        let imageSelected = checkImageSelectionResult.compactMap { $0 }
        let imageDoesntSelected = checkImageSelectionResult
            .filter { $0 == nil }
            .map { _ -> ImageUploadInfo? in nil }
        
        let imageEncodingResult = imageSelected
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .map { image -> ImageUploadInfo? in
                ImageUploadInfo.create(image: image)
            }
            .share()
        
        
        let imageEcodingSuccess = imageEncodingResult.filter { $0 != nil }
        let imageEcodingFailure = mapEndLoading(imageEncodingResult.filter { $0 == nil })
        
        let imageEncodingFailureAlert = imageEcodingFailure.map { _ in
            DefaultAlertContentVO(
                title: "이미지 선택 오류",
                message: "지원하지 않는 이미지 형식입니다."
            )
        }
        
        let imageProcessingFinishWithSuccess = Observable.merge(imageEcodingSuccess, imageDoesntSelected)
        
        
        let editingRequestResult = mapEndLoading(imageProcessingFinishWithSuccess
            .unretained(self)
            .flatMap { (obj, imageInfo) in
                let (phoneNumber, introduction) = obj.checkTextInputModification()
                
                // 변경이 발생하지 않은 곳은 nil값이 전달된다.
                if let _ = phoneNumber { printIfDebug("✅ 전화번호 변경되었음") }
                if let _ = introduction { printIfDebug("✅ 센터소개 변경되었음") }
                if let _ = imageInfo { printIfDebug("✅ 센터 이미지 변경되었음") }
                
                // 전화번호는 무조건 포함시켜야 함으로 변경이 발생하지 않더라도 아래와 같이 포함합니다.
                return obj.profileUseCase.updateProfile(
                    phoneNumber: phoneNumber ?? obj.originalPhonenumber,
                    introduction: introduction,
                    imageInfo: imageInfo
                )
            })
            .share()
        
        let editingValidation = editingRequestResult
            .compactMap { $0.value }
            .map { [readyToFetch] info in
                
                printIfDebug("✅ 정보가 성공적으로 업데이트됨")
                
                // 업데이트된 정보 요청
                readyToFetch.accept(())
                
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
        let editingRequestFailureAlert = editingRequestResult
            .compactMap({ $0.error })
            .map({ error in
                // 변경 실패 Alert
                return DefaultAlertContentVO(
                    title: "프로필 수정 실패",
                    message: error.message
                )
            })
        
        enum Mode {
            case editing, display
        }
        
        let initialMode = BehaviorRelay(value: Mode.display)
        
        let buttonPress = Observable
            .merge(
                editingButtonPressed.map { Mode.editing },
                editingFinishButtonPressed.map { Mode.display }
            )
            .map { mode in
                switch mode {
                case .editing:
                    return true
                case .display:
                    return false
                }
            }
        
        let isEditingMode = Observable
            .merge(
                initialMode.map({ $0 == .editing }),
                buttonPress
            )
            .asDriver(onErrorJustReturn: false)
        
        Observable
            .merge(
                profileRequestFailureAlert,
                editingRequestFailureAlert,
                imageEncodingFailureAlert
            )
            .subscribe(self.alert)
            .disposed(by: disposeBag)
            
        // MARK: Exit Button
        exitButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposeBag)
        
        self.centerName = centerNameDriver
        self.centerLocation = centerAddressDriver
        self.centerPhoneNumber = centerPhoneNumberDriver
        self.centerIntroduction = centerIntroductionDriver
        self.displayingImage = displayingImageDriver
        self.isEditingMode = isEditingMode
        self.editingValidation = editingValidation
    }
    
    func checkTextInputModification() -> (String?, String?) {
        
        let phoneNumber = editingPhoneNumber.value
        let instruction = editingInstruction.value
        
        return (
            phoneNumber == fetchedPhoneNumber ? nil : phoneNumber,
            instruction == fetchedIntroduction ? nil : instruction
        )
    }
}
