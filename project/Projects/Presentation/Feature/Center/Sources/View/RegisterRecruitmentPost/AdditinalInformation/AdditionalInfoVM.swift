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
    
    var preferenceAboutExp: PublishRelay<PreferenceAboutExp?> = .init()
    var applicationMethod: PublishRelay<ApplicationMethod?> = .init()
    var recruitmentDeadline: PublishRelay<RecruitmentDeadline?> = .init()
    var deadlineDate: BehaviorRelay<Date?> = .init(value: nil)
    
    var selectedPreferenceAboutExp: Driver<PreferenceAboutExp?>
    var selectedApplicationMethod: Driver<ApplicationMethod?>
    var selectedRecruitmentDeadline: Driver<RecruitmentDeadline?>
    var selectedDateString: Driver<String?>
    
    var completeState: Driver<AdditinalApplicationInfoState?>
    
    private let state = AdditinalApplicationInfoState()
    
    init() {
        
        // Input
        let deadLineInput = Observable
            .combineLatest(
                recruitmentDeadline,
                deadlineDate
            ).map { [state] (deadline, date) -> Void? in
                state.recruitmentDeadline = deadline
                state.deadlineDate = date
                
                if state.recruitmentDeadline == .specificDate {
                    // 마감 지정일 있는 경우
                    return state.deadlineDate != nil ? () : nil
                } else if state.recruitmentDeadline == .untilApplicationFinished {
                    // 마감 지정일이 없는 경우
                    return ()
                } else {
                    // 타입이 선택되지 않은 경우
                    return nil
                }
            }
        
        completeState = Observable
            .combineLatest(
                preferenceAboutExp,
                applicationMethod,
                deadLineInput
            )
            .map { [state] exp, apply, deadlineValidation -> AdditinalApplicationInfoState? in
                state.preferenceAboutExp = exp
                state.applicationMethod = apply
                
                // 필수값 확인
                if state.preferenceAboutExp != nil,
                   state.applicationMethod != nil,
                   deadlineValidation != nil {
                    
                    
                    printIfDebug("[AdditinalInfoVM] 모든 정보 등록완료")
                    // 모든 조건이 충족된 경우
                    return state
                }
                
                return nil
            }
            .asDriver(onErrorJustReturn: nil)
   
        // Output
        selectedPreferenceAboutExp = preferenceAboutExp
            .asDriver(onErrorJustReturn: nil)
        selectedApplicationMethod = applicationMethod
            .asDriver(onErrorJustReturn: nil)
        selectedRecruitmentDeadline = recruitmentDeadline
            .asDriver(onErrorJustReturn: nil)
        selectedDateString = deadlineDate
            .compactMap { $0 }
            .map { date in
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                
                let str = dateFormatter.string(from: date)
                return str
            }
            .asDriver(onErrorJustReturn: nil)
    }
}
