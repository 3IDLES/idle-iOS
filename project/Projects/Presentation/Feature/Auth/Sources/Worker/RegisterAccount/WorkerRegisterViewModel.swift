//
//  WorkerRegisterViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 7/14/24.
//

import UIKit
import PresentationCore
import Domain
import BaseFeature
import Core


import RxSwift
import RxCocoa

public class WorkerRegisterViewModel: BaseViewModel, ViewModelType {
    
    @Injected var inputValidationUseCase: AuthInputValidationUseCase
    @Injected var authUseCase: AuthUseCase
    
    // Init
    weak var coordinator: WorkerRegisterCoordinator?
    
    public var input: Input = .init()
    public var output: Output = .init()
    
    private let stateObject = WorkerRegisterState()
    
    public init(coordinator: WorkerRegisterCoordinator) {
        self.coordinator = coordinator
        super.init()
        
        setInput()
    }
    
    private func setInput() {
        
        // MARK: 화면 페이지네이션
        input
            .nextButtonClicked
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.next()
            })
            .disposed(by: disposeBag)
        
        input
            .prevButtonClicked
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.prev()
            })
            .disposed(by: disposeBag)
        
        // MARK: 이름 입력
        AuthInOutStreamManager.enterNameInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase) { [weak self] validName in
                // 🚀 상태추적 🚀
                self?.stateObject.name = validName
            }
        
        // MARK: 성별 선택
        output.genderIsSelected = input.selectingGender
            .filter({ $0 != .notDetermined })
            .map { [weak self] gender in
                printIfDebug("선택된 성별: \(gender)")
                self?.stateObject.gender = gender
                return true
            }
            .asDriver(onErrorJustReturn: false)
            
        
        // MARK: 생년월일 입력
        output.edtingBirthYearValidation = input
            .edtingBirthYear
            .map { [unowned self] in
                printIfDebug("입력중인 생년월일: \($0)")
                let isValid = self.validateBirthYear($0)
                if isValid {
                    self.stateObject.birthYear = $0
                }
                return isValid
            }
            .asDriver(onErrorJustReturn: false)
            
        // MARK: 전화번호 입력
        AuthInOutStreamManager.validatePhoneNumberInOut(
            input: input,
            output: output,
            useCase: inputValidationUseCase,
            authUseCase: authUseCase,
            disposeBag: disposeBag
        ) { [weak self] authedPhoneNumber in
                // 🚀 상태추적 🚀
                self?.stateObject.phoneNumber = authedPhoneNumber
            }
        
        // 로그인 완료화면으로 이동
        output
            .loginSuccess?
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showCompleteScreen()
            })
            .disposed(by: disposeBag)
        
        // MARK: 주소 입력
        // 예외적으로 ViewModel에서 구독처리
        input
            .addressInformation
            .subscribe(onNext: { [stateObject] info in
                stateObject.addressInformation = info
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 회원가입 최종 등록
        let registerValidation = mapEndLoading(mapStartLoading(input.completeButtonClicked)
            .flatMap { [authUseCase, stateObject] _ in
                authUseCase.registerWorkerAccount(registerState: stateObject)
            })
            .share()
        
        registerValidation.compactMap { $0.value }
            .subscribe (onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.showCompleteScreen()
            })
            .disposed(by: disposeBag)
        
        let registerFailureAlert = registerValidation.compactMap { $0.error }
            .map { error in
                print("❌ 회원가입 실패 \n 에러내용: \(error.message)")
                return DefaultAlertContentVO(
                    title: "회원가입 실패",
                    message: error.message
                )
            }
        
        Observable
            .merge(
                input.alert,
                registerFailureAlert
            )
            .subscribe(onNext: { [weak self] alertVO in
                
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
    }
    
    private func validateBirthYear(_ year: Int) -> Bool {
        let currentYear: Int = Calendar.current.component(.year, from: Date())
        return (1900..<currentYear).contains(year)
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
        public var nextButtonClicked: PublishSubject<Void> = .init()
        public var prevButtonClicked: PublishSubject<Void> = .init()
        public var completeButtonClicked: PublishSubject<Void> = .init()
        
        // 이름입력, 생년월일 입력, 성별 선택
        public var editingName: PublishRelay<String> = .init()
        public var edtingBirthYear: PublishRelay<Int> = .init()
        public var selectingGender: BehaviorRelay<Gender> = .init(value: .notDetermined)
        
        // 전화번호 입력
        public var editingPhoneNumber: BehaviorRelay<String> = .init(value: "")
        public var editingAuthNumber: BehaviorRelay<String> = .init(value: "")
        public var requestAuthForPhoneNumber: PublishRelay<Void> = .init()
        public var requestValidationForAuthNumber: PublishRelay<Void> = .init()
        
        // 주소 입력
        public var addressInformation: PublishRelay<AddressInformation> = .init()
        
        // Alert
        public var alert: PublishSubject<DefaultAlertContentVO> = .init()
    }
    
    public class Output {
        // 이름 입력
        public var nameValidation: Driver<Bool>?
        public var edtingBirthYearValidation: Driver<Bool>?
        
        // 성별
        public var genderIsSelected: Driver<Bool>?
        
        // 전화번호 입력
        public var canSubmitPhoneNumber: Driver<Bool>?
        public var canSubmitAuthNumber: Driver<Bool>?
        public var phoneNumberValidation: Driver<Bool>?
        public var authNumberValidation: Driver<Bool>?
        
        // 요양보호사 로그인 성공 여부
        public var loginSuccess: Driver<Void>?
    }
}

// CTAButton
extension WorkerRegisterViewModel.Input: PageProcessInputable { }

// Enter personal info
extension WorkerRegisterViewModel.Input: WorkerPersonalInfoInputable { }
extension WorkerRegisterViewModel.Output: WorkerPersonalInfoOutputable { }

// Auth phoneNumber
extension WorkerRegisterViewModel.Input: AuthPhoneNumberInputable { }
extension WorkerRegisterViewModel.Output: AuthPhoneNumberOutputable { }

// Postal code
extension WorkerRegisterViewModel.Input: EnterAddressInputable { }
