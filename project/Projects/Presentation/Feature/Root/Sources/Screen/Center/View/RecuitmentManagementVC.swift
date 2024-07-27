//
//  RecuitmentManagementVC.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import RxCocoa
import RxSwift

public class RecuitmentManagementVC: UIViewController {
    
    weak var coordinator: RecruitmentManagementCoordinator?
    
    public init(coordinator: RecruitmentManagementCoordinator) {
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearacne()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    let dispoesBag = DisposeBag()
    
    private func setAppearacne() {
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "공고 관리"
        
        let button = UIButton()
        button.setTitle("센터정보 등록", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isUserInteractionEnabled = true
        
        button.rx.tap
            .subscribe { [weak coordinator] _ in
                coordinator?.showCenterRegisterScreen()
            }
            .disposed(by: dispoesBag)
        [
            label,
            button,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
        ])
    }
}
