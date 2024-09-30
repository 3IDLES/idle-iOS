//
//  CenterDeregisterReasonsVM.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import BaseFeature
import Domain


import RxSwift
import RxCocoa

public class CenterDeregisterReasonsVM: BaseViewModel, DeregisterReasonVMable {

    public weak var coordinator: SelectReasonCoordinator?
    public var exitButonClicked: RxRelay.PublishRelay<Void> = .init()
    public var acceptDeregisterButonClicked: PublishRelay<[String]> = .init()
    public var userType: UserType = .center
    
    public init(coordinator: SelectReasonCoordinator) {
        self.coordinator = coordinator
        
        super.init()
        
        acceptDeregisterButonClicked
            .subscribe(onNext: { [weak self] reasons in
                self?.coordinator?.showPasswordAuthScreen(reasons: reasons)
            })
            .disposed(by: disposeBag)
        
        exitButonClicked
            .subscribe(onNext: { [weak self] reasons in
                self?.coordinator?.coordinatorDidFinish()
            })
            .disposed(by: disposeBag)
    }
}
