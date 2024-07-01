//
//  ValidatePhoneNumberViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

class ValidatePhoneNumberViewController: DisposableViewController {
    
    var coordinater: Coordinator?
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "폰 번호 검증"
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func cleanUp() {
        
    }
}
