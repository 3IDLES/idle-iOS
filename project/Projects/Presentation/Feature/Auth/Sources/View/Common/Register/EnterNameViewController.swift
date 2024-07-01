//
//  EnterNameViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

class EnterNameViewController: DisposableViewController {
    
    var coordinater: AgentRegisterCoordinator?
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "이름 입력"
        
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
