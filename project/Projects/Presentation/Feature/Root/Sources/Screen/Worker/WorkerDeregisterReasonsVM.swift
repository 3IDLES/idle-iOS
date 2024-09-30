//
//  WorkerDeregisterReasonsVM.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import BaseFeature
import Domain


import RxSwift
import RxCocoa

public class WorkerDeregisterReasonsVM: BaseViewModel, DeregisterReasonVMable {
    
    public weak var coordinator: SelectReasonCoordinator?
    public var exitButonClicked: RxRelay.PublishRelay<Void> = .init()
    public var acceptDeregisterButonClicked: PublishRelay<[String]> = .init()
    public var userType: UserType = .worker
    
    public init(coordinator: SelectReasonCoordinator) {
        self.coordinator = coordinator
        
        super.init()
        
        acceptDeregisterButonClicked
            .subscribe(onNext: { [weak self] reasons in
                self?.coordinator?.showPhoneNumberAuthScreen(reasons: reasons)
            })
            .disposed(by: disposeBag)
        
        exitButonClicked
            .subscribe(onNext: { [weak self] reasons in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
    }
}
