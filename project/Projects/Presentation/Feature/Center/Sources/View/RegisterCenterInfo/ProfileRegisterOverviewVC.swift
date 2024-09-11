//
//  ProfileRegisterOverviewVC.swift
//  CenterFeature
//
//  Created by choijunios on 9/12/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class ProfileRegisterOverviewVC: BaseViewController {
    
    // Init
    
    // View
    lazy var navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(innerViews: [])
        return bar
    }()
    
    let confirmLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "다음의 센터 정보가 맞는지\n확인해주세요"
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    /// Center name label
    let centerNameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        return label
    }()
    
    /// Center location label
    let centerLocationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        
        return label
    }()
    
    /// ☑️ 센터 상세정보 ☑️
    let centerDetailLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.textString = "센터 상세 정보"
        label.textAlignment = .left
        return label
    }()

    /// ☑️ "전화번호" 라벨 ☑️
    let centerPhoneNumeberTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "전화번호"
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    /// 센터 전화번호가 표시되는 라벨
    let centerPhoneNumeberLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    /// ☑️ "센토 소개" 라벨 ☑️
    let centerIntroductionTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "센터 소개"
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    /// 센터 소개가 표시되는 라벨
    let centerIntroductionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.numberOfLines = 0
        return label
    }()
    /// ☑️ "센터 사진" 라벨 ☑️
    let centerPictureLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "센터 사진"
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    private lazy var centerImageView: ImageSelectView = {
        let view = ImageSelectView(state: .editing, viewController: self)
        return view
    }()
    
    // buttons
    let prevButton: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = "이전"
        return button
    }()
    let confirmButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .medium)
        button.label.textString = "확인했어요"
        return button
    }()
    
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        // MARK: UpperView
        let locationIcon = DSIcon.location.image.toView()
        locationIcon.tintColor = DSColor.gray700.color
        let centerLocationLabelStack = HStack([locationIcon,centerLocationLabel], spacing: 2)
        let centerInfoStack = VStack([centerNameLabel, centerLocationLabelStack], spacing: 8, alignment: .leading)
        
        let upperStack = HStack([VStack([confirmLabel, centerInfoStack], spacing: 32, alignment: .leading), Spacer()], alignment: .fill)
        
        let upperStackBackView = UIView()
        upperStackBackView.layoutMargins = .init(
            top: 36,
            left: 20,
            bottom: 24,
            right: 0
        )
        upperStackBackView.addSubview(upperStack)
        upperStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upperStack.topAnchor.constraint(equalTo: upperStackBackView.topAnchor),
            upperStack.leftAnchor.constraint(equalTo: upperStackBackView.leftAnchor),
            upperStack.rightAnchor.constraint(equalTo: upperStackBackView.rightAnchor),
            upperStack.bottomAnchor.constraint(equalTo: upperStackBackView.bottomAnchor),
        ])
        
        // MARK: BelowView
        let phoneNumberStack = VStack([
            centerPhoneNumeberTitleLabel,
            centerPhoneNumeberLabel
        ], alignment: .leading)
        
        let introduceStack = VStack([
            centerIntroductionTitleLabel,
            centerIntroductionLabel
        ], alignment: .leading)
        
        let centerPhotoStack = VStack([
            centerPictureLabel,
            centerImageView
        ], alignment: .leading)
        
        var belowStack = VStack([
            phoneNumberStack,
            introduceStack,
            centerPhotoStack
        ], spacing: 32, alignment: .fill)
        
        belowStack = VStack([
            centerDetailLabel,
            belowStack
        ], alignment: .fill)
        
        let belowStackBackView = UIView()
        belowStackBackView.layoutMargins = .init(
            top: 24,
            left: 20,
            bottom: 48,
            right: 20
        )
        belowStackBackView.addSubview(belowStack)
        belowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            belowStack.topAnchor.constraint(equalTo: belowStackBackView.topAnchor),
            belowStack.leftAnchor.constraint(equalTo: belowStackBackView.leftAnchor),
            belowStack.rightAnchor.constraint(equalTo: belowStackBackView.rightAnchor),
            belowStack.bottomAnchor.constraint(equalTo: belowStackBackView.bottomAnchor),
        ])
        
        // MARK: ButtonStack
        
        let buttonStack = HStack([prevButton, confirmButton], spacing: 8, distribution: .fillEqually)
        buttonStack.layoutMargins = .init(top: 12, left: 20, bottom: 14, right: 20)
        
        let scrollView = UIScrollView()
        
        let divider = Spacer(height: 8)
        divider.backgroundColor = DSColor.gray050.color
        let contentView = VStack([
            upperStackBackView,
            divider,
            belowStackBackView,
            buttonStack,
        ])
       
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentGuide = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
        
        // MARK: main
        
        [
            navigationBar,
            scrollView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind(viewModel: CenterProfileViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // input
        
        rx.viewDidLoad
            .bind(to: viewModel.readyToFetch)
            .disposed(by: disposeBag)
        
        navigationBar
            .backButton
            .rx.tap
            .bind(to: viewModel.exitButtonClicked)
            .disposed(by: disposeBag)
        
        // output
        
        navigationBar.titleLabel.textString = viewModel.navigationBarTitle
        
        viewModel
            .centerName?
            .drive(centerNameLabel.rx.textString)
            .disposed(by: disposeBag)
        
        viewModel
            .centerLocation?
            .drive(centerLocationLabel.rx.textString)
            .disposed(by: disposeBag)
        
        viewModel
            .centerPhoneNumber?
            .drive(centerPhoneNumeberLabel.rx.textString)
            .disposed(by: disposeBag)
        
        viewModel
            .centerIntroduction?
            .drive(centerIntroductionLabel.rx.textString)
            .disposed(by: disposeBag)
        
        viewModel
            .displayingImage?
            .drive(centerImageView.displayingImage)
            .disposed(by: disposeBag)
    }
}

