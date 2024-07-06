//
//  SelectGenderViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import PresentationCore

class SelectGenderViewController: DisposableViewController {
    
    var coordinator: AgentRegisterCoordinator?
    
    public init(coordinator: AgentRegisterCoordinator? = nil) {
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "성별 입력"
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func cleanUp() {
        coordinator?.coordinatorDidFinish()
    }
}
