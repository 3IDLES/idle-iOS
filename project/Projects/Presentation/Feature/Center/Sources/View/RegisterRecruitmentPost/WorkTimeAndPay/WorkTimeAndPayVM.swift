//
//  WorkTimeAndPayViewModel.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//

import RxSwift
import RxCocoa
import Entity
import PresentationCore

class WorkTimeAndPayViewModel: WorkTimeAndPayViewModelable {
    // Input
    var selectedDay: PublishRelay<(DayItem, Bool)> = .init()
    var workStartTime: PublishRelay<String> = .init()
    var workEndTime: PublishRelay<String> = .init()
    var paymentType: PublishRelay<PaymentItem> = .init()
    var paymentAmount: PublishRelay<String> = .init()
    
    // Output
    var selectedPaymentType: Driver<PaymentItem>
    var completeState: Driver<WorkTimeAndPayState>
    
    private let state = WorkTimeAndPayState()
    
    init() {
        
        // Input
        // required
        let selectedDayFinished = selectedDay
            .map { [state] (day, isActive) in
                state.selectedDays[day] = isActive
                // 엑티브 된 요일의 수를 반환
                let activeDayCnt = state.selectedDays.values.reduce(0) { partialResult, isActive in
                    partialResult + (isActive ? 1 : 0)
                }
                return activeDayCnt > 0
            }
            .filter { $0 }
        
        // required
        let workTime = Observable
            .combineLatest(
                selectedDayFinished,
                workStartTime,
                workEndTime
            ).map { [state] (_, start, end) in
                state.workStartTime = start
                state.workEndTime = end
                return ()
            }
        
        // required
        let payment = Observable
            .combineLatest(
                paymentType,
                paymentAmount
            ).map { [state] (type, amount) in
                state.paymentType = type
                state.paymentAmount = amount
                return ()
            }
        
        // Output
        selectedPaymentType = paymentType
            .asDriver(onErrorJustReturn: .timely)
        
        completeState = Observable
            .combineLatest(
                workTime,
                payment
            ).map { [state] _ in
                state
            }
            .asDriver(onErrorJustReturn: WorkTimeAndPayState())
    }
    
}
