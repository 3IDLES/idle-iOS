//
//  AgencyAuthMainViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import DSKit
import PresentationCore

public class AgencyAuthMainViewController: DisposableViewController {

    private lazy var loginButton = ButtonPrototype(text: "로그인") { [weak self] in
        
        self?.coordinator?.parent?.login()
    }
    
    private lazy var registerButton = ButtonPrototype(text: "가입하기") { [weak self] in
        
        self?.coordinator?.parent?.register()
    }
    
    var coordinator: AgencyAuthMainCoordinator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        let title = UILabel()
        title.text = "센터장으로 시작하기"
        title.font = .boldSystemFont(ofSize: 24)
        
        [
            title,
            loginButton,
            registerButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            // 등록 버튼
            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            registerButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // 로그인 버튼
            loginButton.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -10),
            loginButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        
            // 타이틀
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
    }

    public func cleanUp() {
        
    }
}
