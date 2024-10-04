//
//  CenterProfileRegisterOverviewVC.swift
//  CenterCetificatePageFeature
//
//  Created by choijunios on 10/4/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public class MakeCenterProfileOverviewViewController: BaseViewController {
    
    // Init
    
    // View
    lazy var navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(titleText: "센터 정보 등록")
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
        let view = ImageSelectView(state: .normal, viewController: self)
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
        
        let upperStack = HStack([VStack([confirmLabel, centerInfoStack], spacing: 32, alignment: .leading), Spacer()], distribution: .fill)
        
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
            upperStack.topAnchor.constraint(equalTo: upperStackBackView.layoutMarginsGuide.topAnchor),
            upperStack.leftAnchor.constraint(equalTo: upperStackBackView.layoutMarginsGuide.leftAnchor),
            upperStack.rightAnchor.constraint(equalTo: upperStackBackView.layoutMarginsGuide.rightAnchor),
            upperStack.bottomAnchor.constraint(equalTo: upperStackBackView.layoutMarginsGuide.bottomAnchor),
        ])
        
        // MARK: BelowView
        let phoneNumberStack = VStack([
            centerPhoneNumeberTitleLabel,
            centerPhoneNumeberLabel
        ], spacing: 6, alignment: .leading)
        
        let introduceStack = VStack([
            centerIntroductionTitleLabel,
            centerIntroductionLabel
        ], spacing: 6, alignment: .leading)
        
        let centerPhotoStack = VStack([
            centerPictureLabel,
            centerImageView
        ], spacing: 6, alignment: .leading)
        
        var belowStack = VStack([
            phoneNumberStack,
            introduceStack,
            centerPhotoStack
        ], spacing: 32, alignment: .fill)
        
        let buttonStack = HStack([prevButton, confirmButton], spacing: 8, distribution: .fillEqually)
        
        belowStack = VStack([
            centerDetailLabel,
            Spacer(height: 20),
            belowStack,
            Spacer(height: 60),
            buttonStack
        ], alignment: .fill)
        
        let belowStackBackView = UIView()
        belowStackBackView.layoutMargins = .init(
            top: 24,
            left: 20,
            bottom: 14,
            right: 20
        )
        belowStackBackView.addSubview(belowStack)
        belowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            centerImageView.heightAnchor.constraint(equalToConstant: 250),
            
            belowStack.topAnchor.constraint(equalTo: belowStackBackView.layoutMarginsGuide.topAnchor),
            belowStack.leftAnchor.constraint(equalTo: belowStackBackView.layoutMarginsGuide.leftAnchor),
            belowStack.rightAnchor.constraint(equalTo: belowStackBackView.layoutMarginsGuide.rightAnchor),
            belowStack.bottomAnchor.constraint(equalTo: belowStackBackView.layoutMarginsGuide.bottomAnchor),
        ])
        
        let scrollView = UIScrollView()
        
        let divider = Spacer(height: 8)
        divider.backgroundColor = DSColor.gray050.color
        let contentView = VStack([
            upperStackBackView,
            divider,
            belowStackBackView
        ], alignment: .fill)
       
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
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
    func bind(viewModel: MakeCenterProfileOverviewViewModel) {
        
        super.bind(viewModel: viewModel)
        
        // Output
        let ro = viewModel.renderObject
        
        centerNameLabel.textString = ro.centerName
        centerLocationLabel.textString = ro.lotNumberAddress
        centerPhoneNumeberLabel.textString = ro.officeNumber
        centerIntroductionLabel.textString = ro.introduce
        if let imageData = ro.imageInfo?.data {
            DispatchQueue.main.async { [weak self] in
                let image = UIImage(data: imageData)
                self?.centerImageView.displayingImage.accept(image)
            }
        }
        
        // Input
        Observable
            .merge(
                navigationBar.backButton.rx.tap.asObservable(),
                prevButton.rx.tap.asObservable()
            )
            .bind(to: viewModel.backButtonClicked)
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(to: viewModel.requestProfileRegister)
            .disposed(by: disposeBag)
    }
}

