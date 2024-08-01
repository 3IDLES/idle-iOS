//
//  CustomerInformationVM.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//

import RxSwift
import RxCocoa
import Entity
import PresentationCore

class CustomerInformationVM: CustomerInformationViewModelable {
    
    // Input
    var gender: PublishRelay<Gender?> = .init()
    var birthYear: PublishRelay<String> = .init()
    var weight: PublishRelay<String> = .init()
    var careGrade: PublishRelay<CareGrade?> = .init()
    var cognitionState: PublishRelay<CognitionItem?> = .init()
    
    // Optional값이라 스트림에 영향을 없에기 위해 BehaviorRelay를 사용
    var deseaseDescription: BehaviorRelay<String> = .init(value: "")
    
    // Output
    var selectedGender: Driver<Gender?>
    var selectedCareGrade: Driver<CareGrade?>
    var selectedCognitionState: Driver<CognitionItem?>
    var completeState: Driver<CustomerInformationState?>
    
    private let state = CustomerInformationState()
    
    init() {
        
        // Input
        
        // required
        let first2 = Observable
            .combineLatest(
                gender,
                birthYear
            ).map { [state] (gender, year) in
                state.gender = gender
                state.birthYear = year
                
                return ()
            }
        
        // required
        let second3 = Observable
            .combineLatest(
                weight,
                careGrade,
                cognitionState
            ).map { [state] (weight, grade, cogState) in
                state.weight = weight
                state.careGrade = grade
                state.cognitionState = cogState
                
                return ()
            }
        
        // optional
        let deceaseDes = deseaseDescription
            .map { [state] des in
                state.deceaseDescription = des
            }
        
        // Output
        selectedGender = gender.asDriver(onErrorJustReturn: nil)
        selectedCareGrade = careGrade.asDriver(onErrorJustReturn: .one)
        selectedCognitionState = cognitionState.asDriver(onErrorJustReturn: .earlyStage)
        
        completeState = Observable
            .combineLatest(
                first2,
                second3,
                deceaseDes
            )
            .map { [state] _ in
                
                if !state.birthYear.isEmpty,
                   !state.weight.isEmpty,
                   state.careGrade != nil,
                   state.cognitionState != nil,
                   state.gender != nil {
                    
                    return state
                }
                
                return nil
            }
            .asDriver(onErrorJustReturn: nil)
    }
}
