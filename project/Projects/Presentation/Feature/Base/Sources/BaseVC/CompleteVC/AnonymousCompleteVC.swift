//
//  AnonymousCompleteVC.swift
//  BaseFeature
//
//  Created by choijunios on 9/16/24.
//

import UIKit
import PresentationCore
import Domain
import DSKit

import RxCocoa
import RxSwift

public class AnonymousCompleteVC: BaseViewController {
    
    // View
    public let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    public let descriptionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSColor.gray500.color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    
    public let completeButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        return button
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        
        let markImageView = DSKitAsset.Icons.completeMark.image.toView()
        
        let imageLabelStack = VStack(
            [
                markImageView,
                VStack([titleLabel, descriptionLabel], spacing: 11)
            ],
            spacing: 24,
            alignment: .center
        )
        
        let imageLabelStackBackView = UIView()
        [
            imageLabelStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            imageLabelStackBackView.addSubview($0)
        }
        
        
        [
            imageLabelStackBackView,
            completeButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            imageLabelStack.centerXAnchor.constraint(equalTo: imageLabelStackBackView.centerXAnchor),
            imageLabelStack.centerYAnchor.constraint(equalTo: imageLabelStackBackView.centerYAnchor),
        
            imageLabelStackBackView.topAnchor.constraint(equalTo: view.topAnchor),
            imageLabelStackBackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageLabelStackBackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageLabelStackBackView.bottomAnchor.constraint(equalTo: completeButton.topAnchor),
            
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            completeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            completeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }
    
    private func setObservable() { }
    
    public func applyRO(_ ro: AnonymousCompleteVCRenderObject) {
        
        titleLabel.textString = ro.titleText
        descriptionLabel.textString = ro.descriptionText
        completeButton.label.textString = ro.completeButtonText
        
        completeButton.rx.tap
            .subscribe { _ in
                ro.onComplete?()
            }
            .disposed(by: disposeBag)
    }
}
