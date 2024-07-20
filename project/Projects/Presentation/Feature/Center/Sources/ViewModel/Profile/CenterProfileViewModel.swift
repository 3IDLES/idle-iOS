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
    
    private var currentPhoneNumber: String?
    private var currentIntroduction: String?
    private var currentImage: UIImage?
    
    func checkModification(
        prev_phoneNumber: String,
        prev_introduction: String,
        prev_image: UIImage) -> (String?, String?, UIImage?)
    {
        (
            input.editingPhoneNumber.value == prev_phoneNumber ? nil : input.editingPhoneNumber.value,
            input.editingInstruction.value == prev_introduction ? nil : input.editingInstruction.value,
            input.editingImage.value == prev_image ? nil : input.editingImage.value
        )
    }
    
    public init(useCase: CenterProfileUseCase) {
        
        self.profileUseCase = useCase
        
        self.input = Input()
        
        let profileRequestResult = input
            .readyToFetch
            .flatMap { [unowned self] _ in
                self.profileUseCase.getProfile()
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
            .map { [weak self] in
                let name = $0.centerName
                self?.currentPhoneNumber = name
                return name
            }
            .asDriver(onErrorJustReturn: "")

        let centerAddressDriver = profileRequestSuccess
            .map { $0.roadNameAddress }
            .asDriver(onErrorJustReturn: "")
        
        let centerIntroductionDriver = profileRequestSuccess
            .map { [weak self] in
                let introduce = $0.introduce
                self?.currentIntroduction = introduce
                return introduce
            }
            .asDriver(onErrorJustReturn: "")
    
        let centerPhoneNumberDriver = profileRequestSuccess
            .map { $0.officeNumber }
            .asDriver(onErrorJustReturn: "")
        
        let centerImageDriver = profileRequestSuccess
            .map { $0.profileImageURL }
            .compactMap { $0 }
            .observe(on: OperationQueueScheduler.init(operationQueue: .init(), queuePriority: .high))
            .map({ [weak self] imageUrl in
                if let data = try? Data(contentsOf: imageUrl) {
                    let image = UIImage(data: data)
                    self?.currentImage = image
                    return image
                }
                return nil
            })
            .asDriver(onErrorJustReturn: nil)
        
        
        // 최신 값들 + 버튼이 눌릴 경우 변경 로직이 실행된다.
        let editingRequestResult = input
            .editingFinishButtonPressed
            .map({ [unowned self] _ in
                self.checkModification(
                    prev_phoneNumber: self.currentPhoneNumber ?? "",
                    prev_introduction: self.currentIntroduction ?? "",
                    prev_image: self.currentImage ?? .init()
                )
            })
            .flatMap { (inputs) in
                
                let (phoneNumber, introduction, image) = inputs
                
                // 변경이 발생하지 않은 곳은 nil값이 전달된다.
                
                // API 호출
                return Single.just(Result<ChangeCenterInformation, Error>.success(
                    ChangeCenterInformation(
                        phoneNumber: phoneNumber,
                        introduction: introduction,
                        image: image
                    )
                ))
            }
            .share()
        
        // 스트림을 유지하기위해 생성한 Driver로 필수적으로 사용되지 않는다.
        let editingValidation = editingRequestResult
            .compactMap { $0.value }
            .map { [weak self] info in
                
                guard let self else { return () }
                
                if let phoneNumber = info.phoneNumber {
                    printIfDebug("✅ 전화번호 변경 반영되었음")
                    currentPhoneNumber = phoneNumber
                }
                
                if let introduction = info.introduction {
                    printIfDebug("✅ 센터소개 반영되었음")
                    currentIntroduction = introduction
                }
                
                if let image = info.image {
                    printIfDebug("✅ 센터 이미지 변경 반영되었음")
                    currentImage = image
                }
                
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
                editingRequestFailure
            )
            .asDriver(onErrorJustReturn: .default)
        
        self.output = .init(
            centerName: centerNameDriver,
            centerLocation: centerAddressDriver,
            centerPhoneNumber: centerPhoneNumberDriver,
            centerIntroduction: centerIntroductionDriver,
            centerImage: centerImageDriver,
            isEditingMode: isEditingMode,
            editingValidation: editingValidation,
            alert: alertDriver
        )
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
        public var editingImage: BehaviorRelay<UIImage> = .init(value: .init())
    }
    
    class Output: CenterProfileOutputable {
        // 기본 데이터
        public var centerName: Driver<String>
        public var centerLocation: Driver<String>
        public var centerPhoneNumber: Driver<String>
        public var centerIntroduction: Driver<String>
        public var centerImage: Driver<UIImage?>
        
        // 수정 상태 여부
        public var isEditingMode: Driver<Bool>
        
        // 요구사항 X
        public var editingValidation: Driver<Void>
        
        public var alert: Driver<DefaultAlertContentVO>
        
        init(centerName: Driver<String>, centerLocation: Driver<String>, centerPhoneNumber: Driver<String>, centerIntroduction: Driver<String>, centerImage: Driver<UIImage?>, isEditingMode: Driver<Bool>, editingValidation: Driver<Void>, alert: Driver<DefaultAlertContentVO>) {
            self.centerName = centerName
            self.centerLocation = centerLocation
            self.centerPhoneNumber = centerPhoneNumber
            self.centerIntroduction = centerIntroduction
            self.centerImage = centerImage
            self.isEditingMode = isEditingMode
            self.editingValidation = editingValidation
            self.alert = alert
        }
    }
}
