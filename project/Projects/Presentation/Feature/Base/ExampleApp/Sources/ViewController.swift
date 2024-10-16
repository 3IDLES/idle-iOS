//
//  ViewController.swift
//  
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import BaseFeature

class ViewController: BaseViewController {
    
    override func viewDidLoad() {
        
        let initialLabel = UILabel()
        
        initialLabel.text = "Example app"
        
        view.backgroundColor = .white
        
        view.addSubview(initialLabel)
        initialLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

