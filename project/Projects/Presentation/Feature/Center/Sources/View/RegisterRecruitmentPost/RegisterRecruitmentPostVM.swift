//
//  RegisterRecruitmentPostVM.swift
//  CenterFeature
//
//  Created by choijunios on 8/2/24.
//

import RxSwift
import RxCocoa
import Entity
import PresentationCore

class RegisterRecruitmentPostVM: RegisterRecruitmentPostViewModelable {
    
    var customerRequirementState: PublishRelay<CustomerRequirementState> = .init()
    var workTimeAndPayState: PublishRelay<WorkTimeAndPayState> = .init()
    var customerInformationState: PublishRelay<CustomerInformationState> = .init()
    var addtionalApplicationInfoState: PublishRelay<AdditinalApplicationInfoState> = .init()
    var editingAddress: PublishRelay<AddressInformation> = .init()
    var editingDetailAddress: PublishRelay<String> = .init()
    
    var addressValidation: Driver<Bool>?
    var alert: Driver<DefaultAlertContentVO>?
    
    init() {
        
        addressValidation = Observable
            .combineLatest(
                editingAddress,
                editingDetailAddress.filter { !$0.isEmpty }
            )
            .map { (info, detail) in
                
                return true
            }
            .asDriver(onErrorJustReturn: false)
    }
}
