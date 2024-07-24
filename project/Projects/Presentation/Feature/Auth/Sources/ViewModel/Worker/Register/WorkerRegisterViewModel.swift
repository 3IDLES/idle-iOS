//
//  WorkerRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore
import UseCaseInterface
import Entity

public class WorkerRegisterViewModel: ViewModelType {
    
    // UseCase
    public let inputValidationUseCase: AuthInputValidationUseCase
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    private let stateObject = WorkerRegisterState()
    
    public func transform(input: Input) -> Output {
        return output
    }
    
    public init(inputValidationUseCase: AuthInputValidationUseCase) {
        self.inputValidationUseCase = inputValidationUseCase
        
        setInput()
    }
    
    private func setInput() {
        
        // MARK: 이름 입력
        AuthInOutStreamManager.enterNameInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase) { [weak self] validName in
                // 🚀 상태추적 🚀
                self?.stateObject.name = validName
            }
        
        // MARK: 성별 선택
        _ = input
            .selectingGender
            .filter({ $0 != .notDetermined })
            .map({ [weak self] gender in
                printIfDebug("선택된 성별: \(gender)")
                self?.stateObject.gender = gender
                return ()
            })
            .bind(to: output.genderIsSelected)
            
        // MARK: 전화번호 입력
        AuthInOutStreamManager.validatePhoneNumberInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase) { [weak self] authedPhoneNumber in
                // 🚀 상태추적 🚀
                self?.stateObject.phoneNumber = authedPhoneNumber
            }
        
        // MARK: 주소 입력
        _ = input
            .addressInformation
            .compactMap { $0 }
            .map { [unowned self] addressInfo in
                self.stateObject.addressInformation = addressInfo
            }
        
        // MARK: 회원가입 성공 여부
        
        
        let registerValidation = input
            .ctaButtonClicked
            .compactMap { $0 }
            .map { _ in
                
                #if DEBUG
                print("✅ 디버그모드에서 회원가입 무조건 통과")
                return Result<Void, InputValidationError>.success(())
                #endif
                
                //TODO: UseCase사용
                return Result<Void, InputValidationError>.success(())
            }
            .share()
        
        _ = registerValidation
            .compactMap { $0.value }
            .map { [weak self] in
                print("✅ 회원가입 성공")
                self?.output.registerValidation.accept(true)
            }
        
        _ = registerValidation
            .compactMap { $0.error }
            .map { [weak self] error in
                print("❌ 회원가입 실패 \n 에러내용: \(error.message)")
                self?.output.registerValidation.accept(false)
            }
    }
}

extension WorkerRegisterViewModel {
    
    func formatPhoneNumber(phoneNumber: String) -> String {
        let s1 = phoneNumber.startIndex
        let e1 = phoneNumber.index(s1, offsetBy: 3)
        let s2 = e1
        let e2 = phoneNumber.index(s2, offsetBy: 4)
        let s3 = e2
        let e3 = phoneNumber.index(s3, offsetBy: 4)
       
        let formattedString = [
            phoneNumber[s1..<e1],
            phoneNumber[s2..<e2],
            phoneNumber[s3..<e3]
        ].joined(separator: "-")
        
        return formattedString
    }
}

// MARK: ViewModel input output
extension WorkerRegisterViewModel {
    
    public class Input {
        // CTA 버튼 클릭시
        public var ctaButtonClicked: PublishRelay<Void?> = .init()
        
        // 이름입력
        public var editingName: PublishRelay<String?> = .init()
        
        // 성별 선택
        public var selectingGender: BehaviorRelay<Gender> = .init(value: .notDetermined)
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 주소 입력
        public var addressInformation: PublishRelay<AddressInformation?> = .init()
//        public var editingDetailAddress: PublishRelay<String?> = .init()
    }
    
    public class Output {
        // 이름 입력
        public var nameValidation: PublishSubject<(isValid: Bool, name: String)> = .init()
        
        // 성별 선택완료
        public var genderIsSelected: PublishRelay<Void> = .init()
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // 회원가입 성공 여부
        public var registerValidation: PublishRelay<Bool?> = .init()
        
        // Alert
        public var alert: Driver<DefaultAlertContentVO>?
    }
}

// CTAButton
extension WorkerRegisterViewModel.Input: CTAButtonEnableInputable { }

// Enter name
extension WorkerRegisterViewModel.Input: EnterNameInputable { }
extension WorkerRegisterViewModel.Output: EnterNameOutputable { }

// Gender selection
extension WorkerRegisterViewModel.Input: SelectGenderInputable { }
extension WorkerRegisterViewModel.Output: SelectGenderOutputable { }

// Auth phoneNumber
extension WorkerRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension WorkerRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Postal code
extension WorkerRegisterViewModel.Input: EnterAddressInputable { }
extension WorkerRegisterViewModel.Output: EnterAddressOutputable { }

extension WorkerRegisterViewModel.Output: RegisterSuccessOutputable { }
