//
//  CenterProfileRegisterCompleteVC.swift
//  CenterFeature
//
//  Created by choijunios on 9/12/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public class CenterProfileRegisterCompleteVC: BaseViewController {
    
    // Init
    
    // Not init
    weak var coordinator: CenterProfileRegisterCoordinatable?
    
    // View
    private let ctaButton: CTAButtonType1 = {
        let button = CTAButtonType1(labelText: "확인")
        return button
    }()
    
    public init(coordinator: CenterProfileRegisterCoordinatable) {
        self.coordinator = coordinator
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
        let completeLabel = IdleLabel(typography: .Heading1)
        completeLabel.numberOfLines = 2
        completeLabel.textString = "센터 정보를 등록했어요!"
        completeLabel.textAlignment = .center
        
        let imageLabelStack = VStack(
            [
                markImageView,
                completeLabel
            ],
            spacing: 36,
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
            ctaButton
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
            imageLabelStackBackView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            ctaButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            ctaButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }
    
    private func setObservable() {
        
        ctaButton.eventPublisher
            .subscribe { [coordinator] _ in
                coordinator?.registerFinished()
            }
            .disposed(by: disposeBag)
    }
}
