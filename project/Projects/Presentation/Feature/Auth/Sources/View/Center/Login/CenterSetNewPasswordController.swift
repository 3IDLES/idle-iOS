//
//  CenterSetNewPasswordController.swift
//  AuthFeature
//
//  Created by choijunios on 7/1/24.
//

import UIKit
import DSKit
import RxSwift
import RxCocoa
import PresentationCore
import BaseFeature

class CenterSetNewPasswordController: DisposableViewController {
    
    // Init
    var pageViewController: UIPageViewController
    
    let pageCount: Int
    
    var coordinator: CenterSetNewPasswordCoordinator?
    
    let disposeBag = DisposeBag()
    
    public init(pageViewController: UIPageViewController, pageCount: Int) {
        self.pageViewController = pageViewController
        self.pageCount = pageCount
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { nil}
    
    // View
    private let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(titleText: "신규 비밀번호 발급")
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 16, right: 20)   
    }
    
    func setAutoLayout() {
        
        [
            navigationBar,
            pageViewController.view,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            pageViewController.view.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 64),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    func setObservable() {
        
        navigationBar
            .backButton.rx.tap
            .subscribe { [weak self] _ in
                self?.coordinator?.prev()
            }
            .disposed(by: disposeBag)
    }
    
    func cleanUp() {
        
    }
}
