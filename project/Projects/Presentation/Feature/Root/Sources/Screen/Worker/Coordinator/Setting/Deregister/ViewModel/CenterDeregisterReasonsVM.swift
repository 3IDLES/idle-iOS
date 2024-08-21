//
//  CenterDeregisterReasonsVM.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import Entity
import RxSwift
import RxCocoa

public class CenterDeregisterReasonsVM: DeregisterReasonVMable {
    
    public weak var coordinator: SelectReasonCoordinator?
    public var exitButonClicked: RxRelay.PublishRelay<Void> = .init()
    public var acceptDeregisterButonClicked: PublishRelay<[DeregisterReasonVO]> = .init()
    
    let disposeBag = DisposeBag()
    
    public init(coordinator: SelectReasonCoordinator) {
        self.coordinator = coordinator
        
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
