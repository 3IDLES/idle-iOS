//
//  CenterAuthOnboardingVC.swift
//  CenterFeature
//
//  Created by choijunios on 9/8/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class CenterAuthOnboardingVC: BaseViewController {
    
    // Init
    
    // View
    let titleLabel1: IdleLabel = {
        let label = IdleLabel(typography: .Heading3)
        label.attrTextColor = DSColor.orange500.color
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel2: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let onboardingImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    public init(title1Text: String, title2Text: String, image: UIImage) {
        self.titleLabel1.textString = title1Text
        self.titleLabel2.textString = title2Text
        self.onboardingImageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        let labelStack = VStack([
            titleLabel1,
            titleLabel2,
        ], spacing: 4, alignment: .center)
        
        [
            labelStack,
            onboardingImageView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            labelStack.topAnchor.constraint(equalTo: view.topAnchor),
            labelStack.leftAnchor.constraint(equalTo: view.leftAnchor),
            labelStack.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            onboardingImageView.topAnchor.constraint(equalTo: labelStack.bottomAnchor, constant: 32),
            onboardingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setObservable() { }
}

