//
//  DefaultLoadingVC.swift
//  BaseFeature
//
//  Created by choijunios on 9/3/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public protocol DefaultLoadingVMable {
    
    var showLoading: Driver<Void>? { get }
    var dismissLoading: Driver<Void>? { get }
}

public class DefaultLoadingVC: UIViewController {
    
    let customTranstionDelegate = CustomTransitionDelegate()
    
    // Init
    
    // View
    private let loadingView: UIActivityIndicatorView = .init()
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = customTranstionDelegate
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        
        loadingView.startAnimating()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray050.color.withAlphaComponent(0.5)
    }
    
    private func setLayout() {
        [
            loadingView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

