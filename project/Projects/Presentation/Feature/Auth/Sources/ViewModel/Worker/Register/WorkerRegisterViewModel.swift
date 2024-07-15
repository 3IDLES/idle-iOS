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
        _ = input
            .editingName
            .compactMap({ $0 })
            .map { [weak self] name in
                
                guard let self else { return (false, name) }
                
                let isValid = self.inputValidationUseCase.checkNameIsValid(name: name)
                
                if isValid {
                    stateObject.name = name
                }
                
                return (isValid, name)
            }
            .bind(to: output.nameValidation)
        
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
        _ = input
            .editingPhoneNumber
            .compactMap({ $0 })
            .map({ [unowned self] phoneNumber in
                printIfDebug("[CenterRegisterViewModel] 전달받은 전화번호: \(phoneNumber)")
                return self.inputValidationUseCase.checkPhoneNumberIsValid(phoneNumber: phoneNumber)
            })
            .bind(to: output.canSubmitPhoneNumber)
        
        _ = input
            .editingAuthNumber
            .compactMap({ $0 })
            .map({ authNumber in
                printIfDebug("[CenterRegisterViewModel] 전달받은 인증번호: \(authNumber)")
                return authNumber.count >= 6
            })
            .bind(to: output.canSubmitAuthNumber)
        
        let phoneNumberAuthRequestResult = input
            .requestAuthForPhoneNumber
            .compactMap({ $0 })
            .flatMap({ [unowned self] number in
                
                let formatted = self.formatPhoneNumber(phoneNumber: number)
                
                // 상태추적
                self.stateObject.phoneNumber = formatted
                
                #if DEBUG
                print("✅ 디버그모드에서 번호인증 요청 무조건 통과")
                return Single.just(Result<String, InputValidationError>.success(formatted))
                #endif
                
                return self.inputValidationUseCase.requestPhoneNumberAuthentication(phoneNumber: formatted)
            })
            .share()
        
        _ = phoneNumberAuthRequestResult
            .compactMap { $0.value }
            .map { [weak self] phoneNumber in
                printIfDebug("✅ 번호로 인증을 시작합니다.")
                self?.stateObject.phoneNumber = phoneNumber
                return true
            }
            .bind(to: output.phoneNumberValidation)
        
        _ = phoneNumberAuthRequestResult
            .compactMap { $0.error }
            .map { error in
                printIfDebug("❌ 인증을 시작할 수 없습니다. \n 에러내용: \(error.message)")
                return false
            }
            .bind(to: output.phoneNumberValidation)
        
        
        let phoneNumberAuthResult = input.requestValidationForAuthNumber
            .compactMap({ [weak self] authNumber in
                if let phoneNumber = self?.stateObject.phoneNumber, let authNumber {
                    return (phoneNumber, authNumber)
                }
                return nil
            })
            .flatMap { [unowned self] (phoneNumber: String, authNumber: String) in
                
                #if DEBUG
                // 디버그시 인증번호 무조건 통과
                print("✅ 디버그모드에서 번호인증 무조건 통과")
                return Single.just(Result<String, InputValidationError>.success(phoneNumber))
                #endif
                
                return self.inputValidationUseCase
                    .authenticateAuthNumber(phoneNumber: phoneNumber, authNumber: authNumber)
            }
            .share()
        
        // 번호인증 성공
        _ = phoneNumberAuthResult
            .compactMap { $0.value }
            .map { _ in
                printIfDebug("✅ 인증성공")
                return true
            }
            .bind(to: output.authNumberValidation)
    
        // 번호인증 실패
        _ = phoneNumberAuthResult
            .compactMap { $0.error }
            .map { error in
                printIfDebug("❌ 번호 인증실패 \n 에러내용: \(error.message)")
                return false
            }
            .bind(to: output.authNumberValidation)
        
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
            .map {
                print("✅ 회원가입 성공")
                return true
            }
            .bind(to: output.registerValidation)
        
        _ = registerValidation
            .compactMap { $0.error }
            .map({ error in
                print("❌ 회원가입 실패 \n 에러내용: \(error.message)")
                return false
            })
            .bind(to: output.registerValidation)
            
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
        public var editingPhoneNumber: PublishRelay<String?> = .init()
        public var editingAuthNumber: PublishRelay<String?> = .init()
        public var requestAuthForPhoneNumber: PublishRelay<String?> = .init()
        public var requestValidationForAuthNumber: PublishRelay<String?> = .init()
        
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
        public var canSubmitPhoneNumber: PublishRelay<Bool?> = .init()
        public var canSubmitAuthNumber: PublishRelay<Bool?> = .init()
        public var phoneNumberValidation: PublishRelay<Bool?> = .init()
        public var authNumberValidation: PublishRelay<Bool?> = .init()
        
        // 회원가입 성공 여부
        public var registerValidation: PublishRelay<Bool?> = .init()
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
