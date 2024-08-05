//
//  PostOverviewVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/4/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

class SampleTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width, height: contentSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

public class PostOverviewVC: BaseViewController {
    
    // Init
    
    // View
    let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(DSKitAsset.Icons.back.image, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    let postEditButton: TextButtonType2 = {
        let button = TextButtonType2(labelText: "공고 수정하기")
        button.label.typography = .Body3
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        button.layoutMargins = .init(top: 5.5, left:12, bottom: 5.5, right: 12)
        button.layer.cornerRadius = 16
        return button
    }()
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "다음의 공고 정보가 맞지\n확인해주세요."
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    let subtitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle1)
        label.textString = "공고 상세 정보"
        return label
    }()
    
    let sampleCard: WorkerEmployCard = {
        let card = WorkerEmployCard()
        card.starButton.isUserInteractionEnabled = false
        return card
    }()
    
    let screenFoWorkerButton: TextImageButtonType2 = {
        let button = TextImageButtonType2()
        button.textLabel.textString = "보호사 측 화면으로 보기 "
        button.textLabel.attrTextColor = DSKitAsset.Colors.gray300.color
        button.imageView.image = DSKitAsset.Icons.chevronRight.image
        button.imageView.tintColor = DSKitAsset.Colors.gray300.color
        button.layoutMargins = .zero
        button.layer.borderWidth = 0.0
        return button
    }()
    
    // Overviews
    let workConditionOV = WorkConditionOverView()
    let customerInfoOV = CustomerInformationOverView()
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        
        let headerStack = HStack([backButton, postEditButton], 
                                 alignment: .center, distribution: .equalSpacing)
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        let contentView = UIView()
        contentView.layoutMargins = .init(top: 21, left: 20, bottom: 16, right: 20)
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
        ])
        
        // Overview
        
        let overviewData: [(title: String, view: UIView)] = [
            ("근무 조건", workConditionOV),
            ("고객 정보", customerInfoOV)
        ]
        
        let overViews = overviewData.map { (title, view) in
            
            let partView = UIView()
            partView.backgroundColor = .white
            partView.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)
            
            let titleLabel = IdleLabel(typography: .Subtitle1)
            titleLabel.textString = title
            
            [
                titleLabel,
                view
            ].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                partView.addSubview($0)
            }
            
            NSLayoutConstraint.activate([
                
                titleLabel.topAnchor.constraint(equalTo: partView.layoutMarginsGuide.topAnchor),
                titleLabel.leftAnchor.constraint(equalTo: partView.layoutMarginsGuide.leftAnchor),
                
                view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.43),
                view.leftAnchor.constraint(equalTo: partView.layoutMarginsGuide.leftAnchor),
                view.rightAnchor.constraint(equalTo: partView.layoutMarginsGuide.rightAnchor),
                view.bottomAnchor.constraint(equalTo: partView.layoutMarginsGuide.bottomAnchor),
            ])
            
            return partView
        }
        
        let overViewContentView = VStack(
            [
                overViews.map({ view in
                    [
                        Spacer(height: 8),
                        view
                    ]
                }).flatMap { $0 }
            ].flatMap { $0 },
            alignment: .fill
        )
        overViewContentView.backgroundColor = DSKitAsset.Colors.gray050.color
        
        // scroll view
        [
            titleLabel,
            subtitleLabel,
            sampleCard,
            screenFoWorkerButton,
            overViewContentView,
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            subtitleLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
                
            sampleCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            sampleCard.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            sampleCard.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            
            screenFoWorkerButton.topAnchor.constraint(equalTo: sampleCard.bottomAnchor, constant: 12),
            screenFoWorkerButton.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            overViewContentView.topAnchor.constraint(equalTo: screenFoWorkerButton.bottomAnchor, constant: 24),
            overViewContentView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            overViewContentView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            overViewContentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        
        // main view
        [
            headerStack,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            headerStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            headerStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
    }
    
    private func setObservable() {
        
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        sampleCard.bind(vo: .mock)
        
        let bindableViews: [RegisterRecruitmentPostVMBindable] = [
            workConditionOV,
            customerInfoOV,
        ]
        
        bindableViews.forEach { subView in
            subView.bind(viewModel: viewModel)
        }
    }
}

