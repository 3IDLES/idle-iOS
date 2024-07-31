//
//  CustomerRequirementVM.swift
//  CenterFeature
//
//  Created by choijunios on 7/30/24.
//

import RxSwift
import RxCocoa
import Entity
import PresentationCore

class CustomerRequirementVM: CustomerRequirementViewModelable {
    
    // Input
    var mealSupportNeeded: PublishRelay<Bool> = .init()
    var toiletSupportNeeded: PublishRelay<Bool> = .init()
    var movingSupportNeeded: PublishRelay<Bool> = .init()
    var dailySupportTypeNeeded: PublishRelay<(DailySupportType, Bool)> = .init()
    var additionalRequirement: PublishRelay<String> = .init()
    
    let state = CustomerRequirementState()
    
    // Output
    var isMealSupportActvie: Driver<Bool>
    var isToiletSupportActvie: Driver<Bool>
    var isMovingSupportActvie: Driver<Bool>
    var completeState: Driver<CustomerRequirementState>
    
    private let disposeBag = DisposeBag()
    
    init() {
        
        isMealSupportActvie = mealSupportNeeded
            .asDriver(onErrorJustReturn: false)
        
        isToiletSupportActvie = toiletSupportNeeded
            .asDriver(onErrorJustReturn: false)
        
        isMovingSupportActvie = movingSupportNeeded
            .asDriver(onErrorJustReturn: false)
        
        // 3가지 라디오 버튼
        let first3 = Observable
            .combineLatest(
                mealSupportNeeded,
                toiletSupportNeeded,
                movingSupportNeeded
            )
            .map { [state] meal, toilet, moving in
                state.mealSupportNeeded = meal
                state.toiletSupportNeeded = toilet
                state.movingSupportNeeded = moving
                
                printIfDebug("state상태: \(state)")
                
                return state
            }
        
        additionalRequirement
            .subscribe { [state] info in
                printIfDebug("입력중인 요구사항: \(info)")
                state.additionalRequirement = info
            }
            .disposed(by: disposeBag)
        
        dailySupportTypeNeeded
            .subscribe { [state] key, isActive in
                state.dailySupportTypeNeeds[key] = isActive
                
                printIfDebug("일상보조상태: \(state.dailySupportTypeNeeds)")
            }
            .disposed(by: disposeBag)
        
        // 3가지 라디오 버튼에 대한 입력만 필수 입력이다.
        completeState = first3
            .asDriver(onErrorRecover: { _ in fatalError() })
    }
}
