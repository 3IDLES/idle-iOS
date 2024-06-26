//
//  AgentRegisterViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import PresentationCore

class AgentRegisterViewController: DisposableViewController {
    
    var coordinator: AgentRegisterCoordinator?
    
    var pageViewController: UIPageViewController
    
    lazy var nextButton = ButtonPrototype(text: "다음") { [weak self] in
        
        self?.coordinator?.next()
    }
    
    init(pageViewController: UIPageViewController) {
        
        self.pageViewController = pageViewController
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(pageViewController)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let statusView = UILabel()
        
        statusView.textColor = .black
        statusView.text = "스테이터스 바"
        
        [
            statusView,
            pageViewController.view,
            nextButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 100),
            
            pageViewController.view.topAnchor.constraint(equalTo: statusView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20)
        ])
    }
    
    func cleanUp() {
        
        coordinator?.stageViewControllers = []
    }
}
