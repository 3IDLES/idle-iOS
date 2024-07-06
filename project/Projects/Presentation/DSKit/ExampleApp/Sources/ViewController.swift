//
//  ViewController.swift
//  
//
//  Created by 최준영 on 6/19/24.
//

import UIKit
import DSKit
import RxSwift

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        
        let navBar = NavigationBarType1(navigationTitle: "센터 회원가입")
        
        let processStatusBar = ProcessStatusBar(
            processCount: 5,
            startIndex: 0
        )
        navBar
            .eventPublisher
            .subscribe { _ in
                
                processStatusBar.moveToSignal.onNext(.prev)
            }
            .disposed(by: disposeBag)
        
        let iFType1 = IFType1(
            titleText: "테스트",
            placeHolderText: "전화번호를 입력해 주세요",
            submitButtonText: "인증"
        )
        
        let btn1 = ButtonPrototype(
            text: "테스트1",
            onTouch: {
                
                iFType1.textField.createTimer()
                iFType1.textField.startTimer(minute: 5, seconds: 0)
            }
        )
        
        let btn2 = ButtonPrototype(
            text: "테스트2",
            onTouch: {
                
                iFType1.button.setEnabled(!iFType1.button.isEnabled)
                iFType1.textField.setEnabled(!iFType1.textField.isEnabled)
            }
        )
        
        let ctaButton1 = CTAButtonType1(labelText: "이전")
        ctaButton1
            .eventPublisher
            .emit(onNext: { _ in
                
                processStatusBar.moveToSignal.onNext(.prev)
            })
            .disposed(by: disposeBag)
        
        
        let ctaButton2 = CTAButtonType1(labelText: "다음")
        ctaButton2
            .eventPublisher
            .emit(onNext: { _ in
                
                processStatusBar.moveToSignal.onNext(.next)
            })
            .disposed(by: disposeBag)
        
        [
            navBar,
            processStatusBar,
            iFType1,
            btn1,
            btn2,
            ctaButton1,
            ctaButton2,
        ]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
        
        view.addSubview(iFType1)
        iFType1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([

            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                                     
            processStatusBar.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            processStatusBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processStatusBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            iFType1.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iFType1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            iFType1.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ctaButton1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ctaButton1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            ctaButton2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ctaButton2.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ctaButton2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            btn1.bottomAnchor.constraint(equalTo: ctaButton1.topAnchor, constant: -20),
            btn1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            btn1.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            btn2.bottomAnchor.constraint(equalTo: btn1.topAnchor, constant: -20),
            btn2.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            btn2.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

