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
    
    private let registerState = WorkerRegisterState()
    
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
                    registerState.name = name
                }
                
                return (isValid, name)
            }
            .bind(to: output.nameValidation)
        
        _ = input
            .selectingGender
            .filter({ $0 != .notDetermined })
            .map({ [weak self] gender in
                printIfDebug("선택된 성별: \(gender)")
                self?.registerState.gender = gender
                return ()
            })
            .bind(to: output.genderIsSelected)
            
    }
    
}

// MARK: ViewModel input output
extension WorkerRegisterViewModel {
    
    public class Input {
        // CTA 버튼 클릭시
        public var ctaButtonClicked: Observable<CTAButtonAction>?
        
        // 이름입력
        public var editingName: PublishRelay<String?> = .init()
        
        // 성별 선택
        public var selectingGender: BehaviorRelay<Gender> = .init(value: .notDetermined)
        
    }
    
    public class Output {
        // 이름 입력
        public var nameValidation: PublishSubject<(isValid: Bool, name: String)> = .init()
        
        // 성별 선택완료
        public var genderIsSelected: PublishRelay<Void> = .init()
        
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
