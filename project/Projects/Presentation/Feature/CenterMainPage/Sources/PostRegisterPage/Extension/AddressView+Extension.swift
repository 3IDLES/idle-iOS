//
//  AddressView+Extension.swift
//  CenterMainPageFeature
//
//  Created by choijunios on 10/3/24.
//

import Foundation
import BaseFeature

extension AddressView {
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        contentView.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .addressInputNextable?
            .drive(onNext: { [buttonContainer] isNextable in
                buttonContainer.nextButton.setEnabled(isNextable)
            })
            .disposed(by: disposeBag)
    }
}
