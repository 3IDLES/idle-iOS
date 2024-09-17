//
//  ApplicationDetailView.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//


import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class ApplicationDetailView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    public weak var viewController: UIViewController?
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "고객 요구사항을 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    let contentView: ApplicationDetailViewContentView
    
    private let buttonContainer: PrevOrNextContainer = {
        let container = PrevOrNextContainer()
        container.nextButton.setEnabled(false)
        container.nextButton.label.textString = "완료"
        return container
    }()
    lazy var nextButtonClicked: Observable<Void> = buttonContainer.nextBtnClicked.asObservable()
    lazy var prevButtonClicked: Observable<Void> = buttonContainer.prevBtnClicked.asObservable()
    
    private let disposeBag = DisposeBag()
    
    public init(
        viewController: UIViewController
    ) {
        self.contentView = ApplicationDetailViewContentView(
            viewController: viewController
        )
        
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .white
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 24,
            right: 20
        )

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalInset = scrollView.contentInset.left + scrollView.contentInset.right
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -horizontalInset)
        ])
        
        [
            processTitle,
            
            scrollView,
            
            buttonContainer
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: -12),
            
            buttonContainer.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            buttonContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14)
        ])
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        contentView.bind(viewModel: viewModel)
        
        viewModel
            .applicationDetailViewNextable?
            .drive(onNext: { [buttonContainer] nextable in
                buttonContainer.nextButton.setEnabled(nextable)
            })
            .disposed(by: disposeBag)
    }
}

