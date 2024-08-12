//
//  CenterEmployCard.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class CenterEmployCard: TappableUIView {
    
    // Init
    
    // View
    
    // Row1
    let durationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.textColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    
    // Row2
    let poseTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.textColor = DSKitAsset.Colors.gray300.color
        return label
    }()
    
    // Row3
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let informationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    // Row4
    let checkApplyButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .medium)
        btn.label.textString = ""
        return btn
    }()
    
    // Row5
    
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
        
    }
}

