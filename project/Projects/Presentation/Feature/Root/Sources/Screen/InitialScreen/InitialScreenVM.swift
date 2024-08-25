//
//  InitialScreenVM.swift
//  RootFeature
//
//  Created by choijunios on 8/25/24.
//

import RxSwift
import Foundation
import PresentationCore

public class InitialScreenVM {
    
    weak var coordinator: RootCoorinatable?
    
    let disposeBag = DisposeBag()
    
    public init(coordinator: RootCoorinatable? = nil) {
        self.coordinator = coordinator
        
        
        // MARK: 로그아웃, 회원탈퇴시
        NotificationCenter.default.rx.notification(.popToInitialVC)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                
                guard let self else { return }
                
                self.coordinator?.popToRoot()
            })
            .disposed(by: disposeBag)
    }
}
