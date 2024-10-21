//
//  EmptyNotificationPageView.swift
//  NotificationPageFeature
//
//  Created by choijunios on 10/21/24.
//

import UIKit

import BaseFeature
import DSKit


import RxSwift

class EmptyNotificationPageView: UIView {
    
    // Init
    
    // View
    let titleLabel: IdleLabel = {
        let view: IdleLabel = .init(typography: .Heading2)
        return view
    }()
    let descriptionLabel: IdleLabel = {
        let view: IdleLabel = .init(typography: .Body3)
        view.attrTextColor = DSColor.gray300.color
        return view
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init(
        titleText: String,
        descriptionText: String
    ) {
        super.init(frame: .zero)
        
        self.titleLabel.textString = titleText
        self.descriptionLabel.textString = descriptionText
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        let labelStack: DSKit.VStack = .init(
            [titleLabel, descriptionLabel],
            spacing: 8,
            alignment: .center
        )
        
        self.addSubview(labelStack)
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            labelStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
}
