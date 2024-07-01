//
//  SelectAuthTypeViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import PresentationCore

class SelectAuthTypeViewController: DisposableViewController {
    
    var coordinator: SelectAuthTypeCoordinator?
    
    lazy var startAgentButton = ButtonPrototype(text: "요양보호사로 시작") { [weak self] in
        self?.coordinator?.authAgent()
    }
    lazy var startAgencyButton = ButtonPrototype(text: "센터장으로 시작") { [weak self] in
        self?.coordinator?.authAgency()
    }
    lazy var closeButton = ButtonPrototype(text: "닫기") { [weak self] in
        self?.coordinator?.coordinatorDidFinish()
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 사용자로 시작하시겠습니까?"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    init() { 
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [
            titleLabel,
            startAgentButton,
            startAgencyButton,
            closeButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setLayout()
    }
    
    func setLayout() {
        
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Agency Button
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // Agency Button
            startAgencyButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            startAgencyButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            startAgencyButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // Agent Button
            startAgentButton.bottomAnchor.constraint(equalTo: startAgencyButton.topAnchor, constant: -20),
            startAgentButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            startAgentButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
    func cleanUp() {
        
    }
}
