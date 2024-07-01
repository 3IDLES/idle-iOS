//
//  AgencyFindPasswordController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import DSKit
import PresentationCore

class AgencyFindPasswordController: DisposableViewController {
    
    private lazy var setNewPasswordButton = ButtonPrototype(text: "새로운 비밀번호 설정(임시)") { [weak self] in
        
        self?.coordinator?.parent?.setNewPassword()
    }
    
    var coordinator: AgencyFindPasswordCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        let title = UILabel()
        title.text = "비밀번호 찾기/사업자 인증"
        title.font = .boldSystemFont(ofSize: 24)
        
        [
            title,
            setNewPasswordButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        
        NSLayoutConstraint.activate([
        
            // 등록 버튼
            setNewPasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            setNewPasswordButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            setNewPasswordButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // 타이틀
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func cleanUp() {
        
    }
}
