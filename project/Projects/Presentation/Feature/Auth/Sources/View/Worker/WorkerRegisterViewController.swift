//
//  WorkerRegisterViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import DSKit
import RxCocoa
import RxSwift
import PresentationCore

class WorkerRegisterViewController: DisposableViewController {
    
    var coordinator: WorkerRegisterCoordinator?
    
    var pageViewController: UIPageViewController
    
    let pageCount: Int
    
    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(
            navigationTitle: "요양보호사 회원가입"
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
        
        self.pageViewController = pageViewController
        self.pageCount = pageCount
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(pageViewController)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
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
            
            pageViewController.view.topAnchor.constraint(equalTo: statusBar.bottomAnchor, constant: 32),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    func setObservable() {
        navigationBar
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.coordinator?.prev()
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(.workerRegisterProcess)
            .compactMap({ $0.userInfo?["move"] as? String })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] move in
                self?.statusBar.moveToSignal.onNext(move == "next" ? .next : .prev)
            })
            .disposed(by: disposeBag)
    }
    
    
    func cleanUp() {
        
        coordinator?.stageViewControllers = []
    }
}
