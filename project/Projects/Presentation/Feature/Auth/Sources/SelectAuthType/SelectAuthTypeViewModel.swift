//
//  SelectAuthTypeViewModel.swift
//  AuthFeature
//
//  Created by choijunios on 8/27/24.
//

import Foundation
import RxSwift
import RxCocoa
import BaseFeature

class SelectAuthTypeViewModel: BaseViewModel {

    let loginAsCenterButtonClicked: PublishRelay<Void> = .init()
    let registerAsCenterButtonClicked: PublishRelay<Void> = .init()
    let registerAsWorkerButtonClicked: PublishRelay<Void> = .init()
    
    var presentLoginPage: (() -> ())!
    var presentCenterRegisterPage: (() -> ())!
    var presentWorkerRegisterPage: (() -> ())!
    
    override init() {
        
        super.init()
        
        loginAsCenterButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentLoginPage()
            })
            .disposed(by: disposeBag)
        
        registerAsCenterButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentCenterRegisterPage()
            })
            .disposed(by: disposeBag)
        
        registerAsWorkerButtonClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                obj.presentWorkerRegisterPage()
            })
            .disposed(by: disposeBag)
    }
}
