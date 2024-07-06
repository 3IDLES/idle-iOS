//
//  SetIdPasswordViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import PresentationCore

class SetIdPasswordViewController: DisposableViewController {
    
    var coordinater: CenterRegisterCoordinator?
    
    public init(coordinator: Coordinator? = nil) {
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "아이디 패스워드 최초 설정화면"
        
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
