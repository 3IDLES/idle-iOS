//
//  CenterRecruitmentPostBoardVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class CenterRecruitmentPostBoardVC: BaseViewController {
    
    // Init
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "공고 관리"
        return label
    }()
    
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
        
    }
}

