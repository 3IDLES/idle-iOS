//
//  CenterProfileViewModel.swift
//  CenterFeature
//
//  Created by choijunios on 7/18/24.
//

import UIKit
import Entity
import RxSwift
import RxCocoa
import PresentationCore
import UseCaseInterface

public struct ChangeCenterInformation {
    let phoneNumber: String?
    let introduction: String?
    let image: UIImage?
}

public class CenterProfileViewModel: CenterProfileViewModelable {
    
    let profileUseCase: CenterProfileUseCase
    
    public var input: Input
    public var output: Output? = nil
    
    public let profileMode: ProfileMode
    
    private var fetchedPhoneNumber: String?
    private var fetchedIntroduction: String?
    private var fetchedImage: UIImage?
    
    private var editingImageInfo: ImageUploadInfo?
    
    func checkModification() -> (String?, String?, ImageUploadInfo?) {
        
        let phoneNumber = input.editingPhoneNumber.value
        let instruction = input.editingInstruction.value
        
        return (
            phoneNumber == fetchedPhoneNumber ? nil : phoneNumber,
            instruction == fetchedIntroduction ? nil : instruction,
            editingImageInfo
        )
    }
    
    public init(mode: ProfileMode, useCase: CenterProfileUseCase) {
        
        self.profileMode = mode
        self.profileUseCase = useCase
        
        self.input = Input()
        
        // MARK: fetch from server
        let profileRequestResult = input
            .readyToFetch
            .flatMap { [profileMode, profileUseCase] _ in
                profileUseCase.getProfile(mode: profileMode)
            }
            .share()
        
        let profileRequestSuccess = profileRequestResult
            .compactMap { $0.value }
        
        let profileRequestFailure = profileRequestResult
            .compactMap { $0.error }
            .map { error in
                DefaultAlertContentVO(title: "프로필 정보 불러오기 실패", message: error.message)
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
            .filter { !$0.isEmpty }
            .asDriver(onErrorJustReturn: "")
    
        let centerPhoneNumberDriver = profileRequestSuccess
            .map { [weak self] in
                let phoneNumber = $0.officeNumber
                self?.fetchedPhoneNumber = phoneNumber
                return phoneNumber
            }
            .asDriver(onErrorJustReturn: "")
        
        let fetchCenterImage = profileRequestSuccess
            .map { $0.profileImageURL }
            .compactMap { $0 }
            .observe(on: OperationQueueScheduler.init(operationQueue: .init(), queuePriority: .high))
            .map({ [weak self] imageUrl in
                if let data = try? Data(contentsOf: imageUrl) {
                    let image = UIImage(data: data)
                    self?.fetchedImage = image
                    return image
                }
                return nil
            })
        
        // MARK: image validation
        let imageValidationResult = input
            .selectedImage
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
                fetchCenterImage,
                imageValidationResult.compactMap { $0 }
            )
            .asDriver(onErrorJustReturn: .init())
        
        
        // 최신 값들 + 버튼이 눌릴 경우 변경 로직이 실행된다.
        let editingRequestResult = input
            .editingFinishButtonPressed
            .map({ [unowned self] _ in
                checkModification()
            })
            .flatMap { [useCase, input] (inputs) in
                
                let (phoneNumber, introduction, imageInfo) = inputs
                
                // 변경이 발생하지 않은 곳은 nil값이 전달된다.
                if let _ = phoneNumber { printIfDebug("✅ 전화번호 변경되었음") }
                if let _ = introduction { printIfDebug("✅ 센터소개 변경되었음") }
                if let _ = imageInfo { printIfDebug("✅ 센터 이미지 변경되었음") }
                
                // 전화번호는 무조건 포함시켜야 함으로 아래와 같이 포함합니다.
                return useCase.updateProfile(
                    phoneNumber: phoneNumber ?? input.editingPhoneNumber.value,
                    introduction: introduction,
                    imageInfo: imageInfo
                )
            }
            .share()
        
        let editingValidation = editingRequestResult
            .compactMap { $0.value }
            .map { [input] info in
                
                printIfDebug("✅ 정보가 성공적으로 업데이트됨")
                
                // 업데이트된 정보 요청
                input.readyToFetch.accept(())
                
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
        let editingRequestFailure = editingRequestResult
            .compactMap({ $0.error })
            .map({ error in
                // 변경 실패 Alert
                return DefaultAlertContentVO(
                    title: "변경 실패",
                    message: "변경 싪패 이유"
                )
            })
        
        enum Mode {
            case editing, display
        }
        
        let initialMode = BehaviorRelay(value: Mode.display)
        
        let buttonPress = Observable
            .merge(
                input.editingButtonPressed.map { Mode.editing },
                input.editingFinishButtonPressed.map { Mode.display }
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
        
        
        let alertDriver = Observable
            .merge(
                profileRequestFailure,
                editingRequestFailure,
                imageValidationFailure
            )
            .asDriver(onErrorJustReturn: .default)
        
        self.output = .init(
            centerName: centerNameDriver,
            centerLocation: centerAddressDriver,
            centerPhoneNumber: centerPhoneNumberDriver,
            centerIntroduction: centerIntroductionDriver,
            displayingImage: displayingImageDriver,
            isEditingMode: isEditingMode,
            editingValidation: editingValidation,
            alert: alertDriver
        )
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


public extension CenterProfileViewModel {
    
    class Input: CenterProfileInputable {
        
        // ViewController에서 받아오는 데이터
        public var readyToFetch: PublishRelay<Void> = .init()
        public var editingButtonPressed: PublishRelay<Void> = .init()
        public var editingFinishButtonPressed: PublishRelay<Void> = .init()
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingInstruction: BehaviorRelay<String> = .init(value: "")
        public var selectedImage: PublishRelay<UIImage> = .init()
    }
    
    class Output: CenterProfileOutputable {
        // 기본 데이터
        public var centerName: Driver<String>
        public var centerLocation: Driver<String>
        public var centerPhoneNumber: Driver<String>
        public var centerIntroduction: Driver<String>
        public var displayingImage: Driver<UIImage?>
        
        // 수정 상태 여부
        public var isEditingMode: Driver<Bool>
        
        // 요구사항 X
        public var editingValidation: Driver<Void>
        
        public var alert: Driver<DefaultAlertContentVO>?
        
        init(centerName: Driver<String>, centerLocation: Driver<String>, centerPhoneNumber: Driver<String>, centerIntroduction: Driver<String>, displayingImage: Driver<UIImage?>, isEditingMode: Driver<Bool>, editingValidation: Driver<Void>, alert: Driver<DefaultAlertContentVO>) {
            self.centerName = centerName
            self.centerLocation = centerLocation
            self.centerPhoneNumber = centerPhoneNumber
            self.centerIntroduction = centerIntroduction
            self.displayingImage = displayingImage
            self.isEditingMode = isEditingMode
            self.editingValidation = editingValidation
            self.alert = alert
        }
    }
}
