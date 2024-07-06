//
//  CenterLoginViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import DSKit
import PresentationCore

class CenterLoginViewController: DisposableViewController {
    
    private lazy var loginButton = ButtonPrototype(text: "로그인(실행)") { [weak self] in
        
        // 화면 닫기
        self?.coordinator?.parent?.authFinished()
    }
    
    private lazy var findPasswordButton = ButtonPrototype(text: "비밀번호 찾기") { [weak self] in
        
        self?.coordinator?.parent?.findPassword()
    }
    
    var coordinator: CenterLoginCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        let title = UILabel()
        title.text = "로그인 화면: 아이디 패스워드 입력"
        title.font = .boldSystemFont(ofSize: 24)
        
        [
            title,
            loginButton,
            findPasswordButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
        
            // 비밀번호 찾기 버튼
            findPasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            findPasswordButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            findPasswordButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // 로그인 버튼
            loginButton.bottomAnchor.constraint(equalTo: findPasswordButton.topAnchor, constant: -10),
            loginButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        
            // 타이틀
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
    }
    
    func cleanUp() {
        
    }
}
