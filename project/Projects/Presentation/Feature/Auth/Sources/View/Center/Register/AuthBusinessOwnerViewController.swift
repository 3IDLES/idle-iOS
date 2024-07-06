//
//  AuthBusinessOwnerViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

class AuthBusinessOwnerViewController: DisposableViewController {
    
    var coordinater: CenterRegisterCoordinator?
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "사업자 인증 화면"
        
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
