//
//  ViewController.swift
//  
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import DSKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        
        let iFType1 = IFType1(
            titleText: "테스트",
            placeHolderText: "전화번호를 입력해 주세요",
            submitButtonText: "인증"
        )
        
        let btn1 = ButtonPrototype(
            text: "테스트1",
            onTouch: {
                
                iFType1.textField.createTimer()
                iFType1.textField.startTimer(minute: 5, seconds: 0)
            }
        )
        
        let btn2 = ButtonPrototype(
            text: "테스트2",
            onTouch: {
                
                iFType1.button.setEnabled(!iFType1.button.isEnabled)
                iFType1.textField.setEnabled(!iFType1.textField.isEnabled)
            }
        )
        
        let ctaButton = CTAButtonType1(labelText: "다음")
        
        [
            iFType1,
            btn1,
            btn2,
            ctaButton,
        ]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
        
        view.addSubview(iFType1)
        iFType1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iFType1.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iFType1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            iFType1.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            btn1.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -20),
            btn1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            btn1.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            btn2.bottomAnchor.constraint(equalTo: btn1.topAnchor, constant: -20),
            btn2.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            btn2.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

