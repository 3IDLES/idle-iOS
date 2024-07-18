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

public struct ChangeCenterInformation {
    let phoneNumber: String?
    let introduction: String?
    let image: UIImage?
}

public class CenterProfileViewModel: CenterProfileViewModelable {
    
    public var input: Input
    public var output: Output? = nil
    
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
    
    public init() {
        self.input = Input()
        
        let centerName = BehaviorRelay<String>(value: "")
        let centerLocation = BehaviorRelay<String>(value: "")
        let centerPhoneNumber = BehaviorRelay<String>(value: "")
        let centerIntroduction = BehaviorRelay<String>(value: "")
        let centerImage = BehaviorRelay<UIImage>(value: .init())
        
        // 서버로 부터 데이터를 요청하는 API
        centerName.accept("네 얼간이 방문요양센터")
        centerLocation.accept("강남구 삼성동 512-3")
        centerPhoneNumber.accept("(02) 123-4567")
        centerIntroduction.accept("안녕하세요 반갑습니다!")
        centerImage.accept(UIImage())

        
        // 최신 값들 + 버튼이 눌릴 경우 변경 로직이 실행된다.
        let editingRequestResult = input
            .editingFinishButtonPressed
            .map({ [unowned self] _ in
                self.checkModification(
                    prev_phoneNumber: centerPhoneNumber.value,
                    prev_introduction: centerIntroduction.value,
                    prev_image: centerImage.value
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
            .map { info in
                
                if let phoneNumber = info.phoneNumber {
                    printIfDebug("✅ 전화번호 변경 반영되었음")
                    centerPhoneNumber.accept(phoneNumber)
                }
                
                if let introduction = info.introduction {
                    printIfDebug("✅ 센터소개 반영되었음")
                    centerIntroduction.accept(introduction)
                }
                
                if let image = info.image {
                    printIfDebug("✅ 센터 이미지 변경 반영되었음")
                    centerImage.accept(image)
                }
                
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
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
        
        
        let alertDriver = editingRequestResult
            .compactMap({ $0.error })
            .map({ error in
                // 변경 실패 Alert
                return DefaultAlertContentVO(
                    title: "변경 실패",
                    message: "변경 싪패 이유"
                )
            })
            .asDriver(onErrorJustReturn: .default)
        
        self.output = .init(
            centerName: centerName.asDriver(onErrorJustReturn: ""),
            centerLocation: centerLocation.asDriver(onErrorJustReturn: ""),
            centerPhoneNumber: centerPhoneNumber.asDriver(onErrorJustReturn: ""),
            centerIntroduction: centerIntroduction.asDriver(onErrorJustReturn: ""),
            centerImage: centerImage.asDriver(onErrorJustReturn: UIImage()),
            isEditingMode: isEditingMode,
            editingValidation: editingValidation,
            alert: alertDriver
        )
    }
}


public extension CenterProfileViewModel {
    
    class Input: CenterProfileInputable {
        // 모드설정
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
        public var centerImage: Driver<UIImage>
        
        // 수정 상태 여부
        public var isEditingMode: Driver<Bool>
        
        // 요구사항 X
        public var editingValidation: Driver<Void>
        
        public var alert: Driver<DefaultAlertContentVO>
        
        init(centerName: Driver<String>, centerLocation: Driver<String>, centerPhoneNumber: Driver<String>, centerIntroduction: Driver<String>, centerImage: Driver<UIImage>, isEditingMode: Driver<Bool>, editingValidation: Driver<Void>, alert: Driver<DefaultAlertContentVO>) {
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
