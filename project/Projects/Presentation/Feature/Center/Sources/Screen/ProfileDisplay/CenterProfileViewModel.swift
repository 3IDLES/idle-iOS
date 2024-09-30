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

public protocol CenterProfileViewModelable: BaseViewModel, CenterProfileInputable & CenterProfileOutputable {
    var profileMode: ProfileMode { get }
}

public protocol CenterProfileInputable {
    var readyToFetch: PublishRelay<Void> { get }
    var editingButtonPressed: PublishRelay<Void> { get }
    var editingFinishButtonPressed: PublishRelay<Void> { get }
    var editingPhoneNumber: BehaviorRelay<String> { get }
    var editingInstruction: BehaviorRelay<String> { get }
    var selectedImage: PublishRelay<UIImage> { get }
    
    var exitButtonClicked: PublishRelay<Void> { get }
}

public protocol CenterProfileOutputable {
    var navigationBarTitle: String { get }
    var centerName: Driver<String>? { get }
    var centerLocation: Driver<String>? { get }
    var centerPhoneNumber: Driver<String>? { get }
    var centerIntroduction: Driver<String>? { get }
    var displayingImage: Driver<UIImage?>? { get }
    var isEditingMode: Driver<Bool>? { get }
    var editingValidation: Driver<Void>? { get }
}


public class CenterProfileViewModel: BaseViewModel, CenterProfileViewModelable {
    
    @Injected var cacheRepository: CacheRepository
    @Injected var profileUseCase: CenterProfileUseCase
    
    weak var coordinator: CenterProfileCoordinator?
    
    public let profileMode: ProfileMode
    
    private var fetchedPhoneNumber: String?
    private var fetchedIntroduction: String?
    private var fetchedImage: UIImage?
    
    private var editingImageInfo: ImageUploadInfo?
    
    public var readyToFetch: PublishRelay<Void> = .init()
    public var editingButtonPressed: PublishRelay<Void> = .init()
    public var editingFinishButtonPressed: PublishRelay<Void> = .init()
    public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
    public var editingInstruction: BehaviorRelay<String> = .init(value: "")
    public var selectedImage: PublishRelay<UIImage> = .init()
    public var exitButtonClicked: RxRelay.PublishRelay<Void> = .init()
    
    // 기본 데이터
    public let navigationBarTitle: String
    public var centerName: Driver<String>?
    public var centerLocation: Driver<String>?
    public var centerPhoneNumber: Driver<String>?
    public var centerIntroduction: Driver<String>?
    public var displayingImage: Driver<UIImage?>?
    
    // 수정 상태 여부
    public var isEditingMode: Driver<Bool>?
    
    // 요구사항 X
    public var editingValidation: Driver<Void>?
    
    // Image
    private let imageDownLoadScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    func checkModification() -> (String?, String?, ImageUploadInfo?) {
        
        let phoneNumber = editingPhoneNumber.value
        let instruction = editingInstruction.value
        
        return (
            phoneNumber == fetchedPhoneNumber ? nil : phoneNumber,
            instruction == fetchedIntroduction ? nil : instruction,
            editingImageInfo
        )
    }
    
    public init(mode: ProfileMode, coordinator: CenterProfileCoordinator) {
        
        self.profileMode = mode
        self.coordinator = coordinator
        
        let navigationBarTitle = (mode == .myProfile ? "내 센터 정보" : "센터 정보")
        self.navigationBarTitle = navigationBarTitle
        
        super.init()
        
        // MARK: fetch from server
        let profileRequestResult = readyToFetch
            .flatMap { [profileMode, profileUseCase] _ in
                profileUseCase.getProfile(mode: profileMode)
            }
            .share()
        
        let profileRequestSuccess = profileRequestResult
            .compactMap { $0.value }
            .share()
        
        let profileRequestFailure = profileRequestResult
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
                return phoneNumber
            }
            .asDriver(onErrorJustReturn: "")
        
        let fetchCenterImageInfo = profileRequestSuccess
            .compactMap { $0.profileImageInfo }
            .observe(on: imageDownLoadScheduler)
            .flatMap { [cacheRepository] downloadInfo in
                cacheRepository
                    .getImage(imageInfo: downloadInfo)
            }.map { image -> UIImage? in
                image
            }
        
        // MARK: image validation
        let imageValidationResult = selectedImage
            .map { [unowned self] image -> UIImage? in
                guard let imageInfo = self.validateSelectedImage(image: image) else { return nil }
                printIfDebug("✅ 업로드 가능한 이미지 타입 \(imageInfo.ext)")
                self.editingImageInfo = imageInfo
                return image
            }
            .share()
        
        let imageValidationFailure = imageValidationResult
            .filter { $0 == nil }
            .map { _ in
                DefaultAlertContentVO(
                    title: "이미지 선택 오류",
                    message: "지원하지 않는 이미지 형식입니다."
                )
            }
        
        let displayingImageDriver = Observable
            .merge(
                fetchCenterImageInfo,
                imageValidationResult
            )
            .asDriver(onErrorJustReturn: .init())
        
        
        // 최신 값들 + 버튼이 눌릴 경우 변경 로직이 실행된다.
        let editingRequestResult = mapEndLoading(mapStartLoading(editingFinishButtonPressed.asObservable())
            .map({ [unowned self] _ in
                checkModification()
            })
            .flatMap { [profileUseCase, editingPhoneNumber] (inputs) in
                
                let (phoneNumber, introduction, imageInfo) = inputs
                
                // 변경이 발생하지 않은 곳은 nil값이 전달된다.
                if let _ = phoneNumber { printIfDebug("✅ 전화번호 변경되었음") }
                if let _ = introduction { printIfDebug("✅ 센터소개 변경되었음") }
                if let _ = imageInfo { printIfDebug("✅ 센터 이미지 변경되었음") }
                
                // 전화번호는 무조건 포함시켜야 함으로 아래와 같이 포함합니다.
                return profileUseCase.updateProfile(
                    phoneNumber: phoneNumber ?? editingPhoneNumber.value,
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
        
        let editingRequestFailure = editingRequestResult
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
                profileRequestFailure,
                editingRequestFailure,
                imageValidationFailure
            )
            .subscribe(self.alert)
            .disposed(by: disposeBag)
            
        // MARK: Exit Button
        exitButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.coordinatorDidFinish()
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
    
    func validateSelectedImage(image: UIImage) -> ImageUploadInfo? {
        .create(image: image)
    }
}
