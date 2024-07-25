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
    
    private let disposeBag = DisposeBag()
    
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
        // 예외적으로 ViewModel에서 구독처리
        input
            .selectingGender
            .filter({ $0 != .notDetermined })
            .subscribe { [weak self] gender in
                printIfDebug("선택된 성별: \(gender)")
                self?.stateObject.gender = gender
            }
            .disposed(by: disposeBag)
            
        // MARK: 전화번호 입력
        AuthInOutStreamManager.validatePhoneNumberInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase) { [weak self] authedPhoneNumber in
                // 🚀 상태추적 🚀
                self?.stateObject.phoneNumber = authedPhoneNumber
            }
        
        // MARK: 주소 입력
        // 예외적으로 ViewModel에서 구독처리
        input
            .addressInformation
            .subscribe { [unowned self] info in
                self.stateObject.addressInformation = info
            }
            .disposed(by: disposeBag)
        
        registerInOut()
    }
    
    func registerInOut() {
        
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
        
        output.registerValidation = registerValidation
            .compactMap { $0.value }
            .map {
                print("✅ 회원가입 성공")
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
        let registerFailure = registerValidation
            .compactMap { $0.error }
            .map { error in
                print("❌ 회원가입 실패 \n 에러내용: \(error.message)")
                return DefaultAlertContentVO(
                    title: "회원가입 실패",
                    message: error.message
                )
            }
        
        // 이미 alert드라이버가 존재할 경우 merge
        var newAlertDrvier: Observable<DefaultAlertContentVO>!
        if let alertDrvier = output.alert {
            newAlertDrvier = Observable
                .merge(
                    alertDrvier.asObservable(),
                    registerFailure
                )
        } else {
            newAlertDrvier = registerFailure
        }
        output
            .alert = newAlertDrvier.asDriver(onErrorJustReturn: .default)
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
        public var ctaButtonClicked: PublishRelay<Void> = .init()
        
        // 이름입력
        public var editingName: PublishRelay<String> = .init()
        
        // 성별 선택
        public var selectingGender: BehaviorRelay<Gender> = .init(value: .notDetermined)
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 주소 입력
        public var addressInformation: PublishRelay<AddressInformation> = .init()
//        public var editingDetailAddress: PublishRelay<String?> = .init()
    }
    
    public class Output {
        // 이름 입력
        public var nameValidation: Driver<Bool>?
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // 회원가입 성공 여부
        public var registerValidation: Driver<Void>?
        
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

// Auth phoneNumber
extension WorkerRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension WorkerRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Postal code
extension WorkerRegisterViewModel.Input: EnterAddressInputable { }

extension WorkerRegisterViewModel.Output: RegisterValidationOutputable { }
