//
//  ViewController.swift
//  
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import CenterFeature

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        
        let initialLabel = CustomerInformationView()
        
        view.backgroundColor = .white
        
        view.addSubview(initialLabel)
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            initialLabel.topAnchor.constraint(equalTo: view.topAnchor),
            initialLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            initialLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            initialLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

