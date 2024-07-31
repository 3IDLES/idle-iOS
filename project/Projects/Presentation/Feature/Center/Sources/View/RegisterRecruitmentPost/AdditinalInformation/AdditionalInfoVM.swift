//
//  AdditionalInfoVM.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//

import Foundation
import RxSwift
import RxCocoa
import Entity
import PresentationCore

class AdditinalInfoVM: AdditinalApplicationInfoViewModelable {
    
    var preferenceAboutExp: PublishRelay<PreferenceAboutExp> = .init()
    var applicationMethod: PublishRelay<ApplicationMethod> = .init()
    var recruitmentDeadline: PublishRelay<RecruitmentDeadline> = .init()
    var deadlineDate: BehaviorRelay<Date> = .init(value: .init())
    
    var selectedPreferenceAboutExp: Driver<PreferenceAboutExp>
    var selectedApplicationMethod: Driver<ApplicationMethod>
    var selectedRecruitmentDeadline: Driver<RecruitmentDeadline>
    var completeState: Driver<AdditinalApplicationInfoState>
    
    private let state = AdditinalApplicationInfoState()
    
    init() {
        
        // Input
        let deadLineInput = Observable
            .combineLatest(
                recruitmentDeadline,
                deadlineDate
            ).map { [state] (deadline, date) in
                state.recruitmentDeadline = deadline
                state.deadlineDate = date
                return ()
            }
        
        completeState = Observable
            .combineLatest(
                preferenceAboutExp,
                applicationMethod,
                deadLineInput
            )
            .map { [state] exp, apply, _ in
                state.preferenceAboutExp = exp
                state.applicationMethod = apply
                
                return state
            }
            .asDriver(onErrorJustReturn: .init())
   
        // Output
        selectedPreferenceAboutExp = preferenceAboutExp.asDriver(onErrorJustReturn: .beginnerPossible)
        selectedApplicationMethod = applicationMethod.asDriver(onErrorJustReturn: .app)
        selectedRecruitmentDeadline = recruitmentDeadline.asDriver(onErrorJustReturn: .untilApplicationFinished)
    }
}
