//
//  WorkerAuthMainViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import PresentationCore

public class WorkerAuthMainViewController: DisposableViewController {
    
    var coordinator: WorkerAuthMainCoodinator?
    
    lazy var startRegisterButton = ButtonPrototype(text: "요양보호사 등록") { [weak self] in
        
        self?.coordinator?.register()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let title = UILabel()
        title.text = "요양보호사 등록"
        title.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        title.textColor = .black
        
        [
            title,
            startRegisterButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            startRegisterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            startRegisterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startRegisterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    public func cleanUp() {
        
    }
}
