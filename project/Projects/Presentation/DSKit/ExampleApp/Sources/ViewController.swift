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
        
        let btn = ButtonPrototype(
            text: "테스트",
            onTouch: {
                
                iFType1.resignFirstResponder()
            }
        )
        
        [
            iFType1,
            btn
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
            
            btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            btn.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

