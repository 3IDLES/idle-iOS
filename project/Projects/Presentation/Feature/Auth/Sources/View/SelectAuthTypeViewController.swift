//
//  SelectAuthTypeViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import RxSwift
import RxCocoa
import PresentationCore

class SelectAuthTypeViewController: DisposableViewController {
    
    var coordinator: SelectAuthTypeCoordinator?
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "어플 소개 한줄 정도\n그리고 어플 이름"
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    let startCenterManagerBtn = TextImageButtonType1(
        titleText: "센터 관리자로\n시작하기",
        labelImage: UIImage()
    )
    
    let startWorkerBtn = TextImageButtonType1(
        titleText: "요양 보호사로\n시작하기",
        labelImage: UIImage()
    )
    
    let disposeBag = DisposeBag()
    
    init() { 
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    func setApearance() {
        
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 80, left: 20, bottom: 0, right: 20)
    }
    
    func setAutoLayout() {
        
        let btnStack = UIStackView()
        
        btnStack.axis = .horizontal
        btnStack.spacing = 4
        btnStack.distribution = .fillEqually
        
        [
            startCenterManagerBtn,
            startWorkerBtn
        ].forEach {
            btnStack.addArrangedSubview($0)
        }
        
        let stackForCentring = UIView()
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        stackForCentring.addSubview(btnStack)
        
        [
            titleLabel,
            stackForCentring,
        ]
        .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            
            stackForCentring.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stackForCentring.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackForCentring.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackForCentring.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
            btnStack.centerYAnchor.constraint(equalTo: stackForCentring.centerYAnchor),
            btnStack.leadingAnchor.constraint(equalTo: stackForCentring.leadingAnchor),
            btnStack.trailingAnchor.constraint(equalTo: stackForCentring.trailingAnchor),
        ])
    }
    
    func setObservable() {
        
        startCenterManagerBtn
            .eventPublisher
            .emit { [weak self] _ in
                self?.coordinator?.authCenter()
            }
            .disposed(by: disposeBag)
        
        startWorkerBtn
            .eventPublisher
            .emit { [weak self] _ in
                self?.coordinator?.authWorker()
            }
            .disposed(by: disposeBag)
    }
    
    func cleanUp() {
        
    }
}
