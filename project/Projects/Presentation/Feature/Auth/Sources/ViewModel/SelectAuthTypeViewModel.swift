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
    
    weak var coordinator: SelectAuthTypeCoordinator?
    
    let loginAsCenterButtonClicked: PublishRelay<Void> = .init()
    let registerAsCenterButtonClicked: PublishRelay<Void> = .init()
    let registerAsWorkerButtonClicked: PublishRelay<Void> = .init()
    
    init(coordinator: SelectAuthTypeCoordinator?) {
        self.coordinator = coordinator
        
        super.init()
        
        loginAsCenterButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.startCenterLoginFlow()
            })
            .disposed(by: disposeBag)
        
        registerAsCenterButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.registerAsCenter()
            })
            .disposed(by: disposeBag)
        
        registerAsWorkerButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.registerAsWorker()
            })
            .disposed(by: disposeBag)
    }
}
