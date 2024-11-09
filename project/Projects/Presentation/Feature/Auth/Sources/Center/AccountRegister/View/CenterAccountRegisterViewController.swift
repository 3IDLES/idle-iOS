//
//  CenterRegisterViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import DSKit
import PresentationCore
import BaseFeature


import RxCocoa
import RxSwift

class CenterAccountRegisterViewController: DisposableViewController {
    
    var exitPage: (() -> ())!
    
    var pageViewController: UIPageViewController
    
    let pageCount: Int
    
    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(
            navigationTitle: "센터관리자 회원가입"
        )
        return bar
    }()
    
    lazy var statusBar: ProcessStatusBar = {
        
        let view = ProcessStatusBar(
            processCount: pageCount,
            startIndex: 0
        )
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    init(
        pageCount: Int,
        pageViewController: UIPageViewController
    ) {
        
        self.pageCount = pageCount
        self.pageViewController = pageViewController
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(pageViewController)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {

    }
    
    func setAppearance() {
        
        view.backgroundColor = .white
    }
    
    func setAutoLayout() {
        
        [
            navigationBar,
            statusBar,
            pageViewController.view,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            statusBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 7),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pageViewController.view.topAnchor.constraint(equalTo: statusBar.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    func setObservable() {
        navigationBar
            .eventPublisher
            .unretained(self)
            .subscribe { (obj, _) in
                obj.exitPage()
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.centerRegisterProcess)
            .compactMap({ $0.userInfo?["move"] as? String })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] move in
                self?.statusBar.moveToSignal.onNext(move == "next" ? .next : .prev)
            })
            .disposed(by: disposeBag)
    }
    
    func cleanUp() {
        
    }
}

