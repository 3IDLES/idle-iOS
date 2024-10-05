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
    
    // Navigation
    var presentPhonenumberAuthPage: (([String]) -> ())?
    var exitPage: (() -> ())?
    
    public var exitButonClicked: RxRelay.PublishRelay<Void> = .init()
    public var acceptDeregisterButonClicked: PublishRelay<[String]> = .init()
    public var userType: UserType = .worker
    
    public override init() {
        
        super.init()
        
        acceptDeregisterButonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, reasons) in
                obj.presentPhonenumberAuthPage?(reasons)
            })
            .disposed(by: disposeBag)
        
        exitButonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.exitPage?()
            })
            .disposed(by: disposeBag)
    }
}
