//
//  WorkerAuthMainViewController.swift
//  AuthFeature
//
//  Created by choijunios on 6/30/24.
//

import UIKit
import Entity
import DSKit
import RxSwift
import RxCocoa
import PresentationCore

public class WorkerAuthMainViewController: DisposableViewController {
    
    var coordinator: WorkerAuthMainCoodinator?
    
    private let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "요양 보호사님, 환영합니다!"
        return label
    }()
    private let titleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .cyan
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    

    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "휴대폰 번호로 시작하기")
        
        return button
    }()
    
    
    let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setAppearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 16, right: 20)
    }
    
    func setAutoLayout() {
        
        let titleStack = VStack([
            titleLabel,
            titleImage
        ], spacing: 32,alignment: .center)
        
        let titleStackCenteringView = UIView()
        titleStackCenteringView.backgroundColor = .clear
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStackCenteringView.addSubview(titleStack)
        
        [
            titleStackCenteringView,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            titleStack.centerXAnchor.constraint(equalTo: titleStackCenteringView.centerXAnchor),
            titleStack.centerYAnchor.constraint(equalTo: titleStackCenteringView.centerYAnchor),
            
            titleImage.widthAnchor.constraint(equalToConstant: 120),
            titleImage.heightAnchor.constraint(equalTo: titleImage.widthAnchor),
            
            titleStackCenteringView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleStackCenteringView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleStackCenteringView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleStackCenteringView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
        
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    func setObservable() {
        
        ctaButton
            .eventPublisher
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.parent?.register()
            })
            .disposed(by: disposeBag)
    }
    
    
    public func cleanUp() {
        
    }
}
