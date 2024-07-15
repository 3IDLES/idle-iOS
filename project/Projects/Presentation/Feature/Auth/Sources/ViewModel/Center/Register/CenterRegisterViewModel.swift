//
//  CenterRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/6/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore
import UseCaseInterface
import Entity

public class CenterRegisterViewModel: ViewModelType {
    
    // UseCase
    public let inputValidationUseCase: AuthInputValidationUseCase
    public let authUseCase: AuthUseCase
    
    // Input은 모든 ViewController에서 공유한다. (다만, 각가의 ViewController의 Input프로토콜에 의해 제한된다.)
    public let input = Input()
    public let output = Output()
    
    internal let stateObject = CenterRegisterState()
        
    public init(
        inputValidationUseCase: AuthInputValidationUseCase,
        authUseCase: AuthUseCase) {
            self.inputValidationUseCase = inputValidationUseCase
            self.authUseCase = authUseCase
            
            enterNameInOut()
            validatePhoneNumberInOut()
            registerInOut()
            validateBusinessNumberInOut()
            IdPasswordInOut()
    }
    
    deinit {
        printIfDebug("deinit \(Self.self)")
    }
}

extension CenterRegisterViewModel {
    
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
    
    func formatBusinessNumber(businessNumber: String) -> String {
        
        let s1 = businessNumber.startIndex
        let e1 = businessNumber.index(s1, offsetBy: 3)
        let s2 = e1
        let e2 = businessNumber.index(s2, offsetBy: 2)
        let s3 = e2
        let e3 = businessNumber.index(s3, offsetBy: 5)
       
        let formattedString = [
            businessNumber[s1..<e1],
            businessNumber[s2..<e2],
            businessNumber[s3..<e3]
        ].joined(separator: "-")
        
        return formattedString
    }
}

// MARK: ViewModel input output
extension CenterRegisterViewModel {
    
    public class Input {
        
        // CTA 버튼 클릭시
        public var ctaButtonClicked: PublishRelay<Void?> = .init()
        
        // 이름입력
        public var editingName: PublishRelay<String?> = .init()
        
        // 전화번호 입력
        public var editingPhoneNumber: PublishRelay<String?> = .init()
        public var editingAuthNumber: PublishRelay<String?> = .init()
        public var requestAuthForPhoneNumber: PublishRelay<String?> = .init()
        public var requestValidationForAuthNumber: PublishRelay<String?> = .init()
        
        // 사업자 번호 입력
        public var editingBusinessNumber: PublishRelay<String?> = .init()
        public var requestBusinessNumberValidation: PublishRelay<String?> = .init()
        
        // Id & password
        public var editingId: PublishRelay<String?> = .init()
        public var editingPassword: PublishRelay<(pwd: String, cpwd: String)?> = .init()
        public var requestIdDuplicationValidation: PublishRelay<String?> = .init()
    }
    
    public class Output {
        
        // 이름 입력
        public var nameValidation: PublishSubject<(isValid: Bool, name: String)> = .init()
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: PublishRelay<Bool?> = .init()
        public var canSubmitAuthNumber: PublishRelay<Bool?> = .init()
        public var phoneNumberValidation: PublishRelay<Bool?> = .init()
        public var authNumberValidation: PublishRelay<Bool?> = .init()
        
        // 사업자 번호 입력
        public var canSubmitBusinessNumber: PublishRelay<Bool?> = .init()
        public var businessNumberValidation: PublishRelay<BusinessInfoVO?> = .init()
        
        // Id & password
        public var canCheckIdDuplication: PublishRelay<Bool?> = .init()
        public var idDuplicationValidation: PublishRelay<String?> = .init()
        public var passwordValidation: PublishRelay<PasswordValidationState?> = .init()
        
        // Register success
        public var registerValidation: PublishRelay<Bool?> = .init()
    }
}

// MARK: Input Validation

// CTAButton
extension CenterRegisterViewModel.Input: CTAButtonEnableInputable { }

// Enter name
extension CenterRegisterViewModel.Input: EnterNameInputable { }
extension CenterRegisterViewModel.Output: EnterNameOutputable { }

// Auth phoneNumber
extension CenterRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension CenterRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Auth Business owner
extension CenterRegisterViewModel.Input: AuthBusinessOwnerInputable { }
extension CenterRegisterViewModel.Output: AuthBusinessOwnerOutputable { }

// Id & Password
extension CenterRegisterViewModel.Input: SetIdPasswordInputable { }
extension CenterRegisterViewModel.Output: SetIdPasswordOutputable { }

// Register
extension CenterRegisterViewModel.Output: RegisterSuccessOutputable { }
