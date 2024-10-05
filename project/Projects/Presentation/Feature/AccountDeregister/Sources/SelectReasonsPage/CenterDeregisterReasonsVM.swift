//
//  CenterDeregisterReasonsVM.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 8/21/24.
//

import BaseFeature
import Domain


import RxSwift
import RxCocoa

public class CenterDeregisterReasonsVM: BaseViewModel, DeregisterReasonVMable {
    
    // Navigation
    var presentPasswordAuthPage: (([String]) -> ())?
    var exitPage: (() -> ())?

    public var exitButonClicked: RxRelay.PublishRelay<Void> = .init()
    public var acceptDeregisterButonClicked: PublishRelay<[String]> = .init()
    public var userType: UserType = .center
    
    public override init() {
        
        super.init()
        
        acceptDeregisterButonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, reasons) in
                obj.presentPasswordAuthPage?(reasons)
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
