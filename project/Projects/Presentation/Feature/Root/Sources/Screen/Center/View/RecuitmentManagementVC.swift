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
        
        let button1 = UIButton()
        button1.setTitle("센터정보 등록", for: .normal)
        button1.setTitleColor(.black, for: .normal)
        button1.isUserInteractionEnabled = true
        
        let button2 = UIButton()
        button2.setTitle("공고 등록", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.isUserInteractionEnabled = true
        
        [
            label,
            button1,
            button2,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button1.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            
            button2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 15),
        ])
    }
}
