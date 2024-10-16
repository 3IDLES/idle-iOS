//
//  CenterProfileViewController.swift
//  CenterFeature
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import PresentationCore
import Domain
import BaseFeature
import DSKit


import RxSwift
import RxCocoa


class CenterProfileViewController: BaseViewController {
    
    // View
    lazy var navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(innerViews: [profileEditButton, editingCompleteButton])
        return bar
    }()
    
    let editingCompleteButton: TextButtonType3 = {
        let btn = TextButtonType3(typography: .Subtitle2)
        btn.textString = "저장"
        btn.attrTextColor = DSKitAsset.Colors.orange500.color
        return btn
    }()
    
    let profileEditButton: TextButtonType2 = {
        let button = TextButtonType2(labelText: "수정하기")
        
        button.label.typography = .Body3
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        button.layoutMargins = .init(top: 5.5, left:12, bottom: 5.5, right: 12)
        button.layer.cornerRadius = 16
        return button
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
        let label = IdleLabel(typography: .Subtitle1)
        label.textString = "센터 상세 정보"
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
    /// 센터 전화번호를 편집할 수 있는 텍스트 필드
    let centerPhoneNumeberField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "추가적으로 요구사항이 있다면 작성해주세요."
        )
        textView.textContainerInset = .init(top: 10, left: 16, bottom: 10, right: 24)
        textView.isScrollEnabled = false
        return textView
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
    /// 센터 소개를 수정하는 텍스트 필드
    let centerIntroductionField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "추가적으로 요구사항이 있다면 작성해주세요."
        )
        return textView
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
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        view.backgroundColor = .white
    }
    
    func setAutoLayout() {
        
        let locationIcon = UIImageView.locationMark
        locationIcon.tintColor = DSColor.gray700.color
        
        let centerLocationStack = HStack(
            [
                locationIcon,
                centerLocationLabel
            ],
            spacing: 2,
            alignment: .center
        )
        
        let centerPhoneNumberStack = VStack(
            [
                centerPhoneNumeberTitleLabel,
                centerPhoneNumeberLabel,
                centerPhoneNumeberField,
            ],
            spacing: 6,
            alignment: .fill
        )
        
        let centerIntroductionStack = VStack(
            [
                centerIntroductionTitleLabel,
                centerIntroductionLabel,
                centerIntroductionField,
            ],
            spacing: 6,
            alignment: .fill
        )
        
        let scrollView = UIScrollView()
        
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        [
            centerNameLabel,
            centerLocationStack,
            
            divider,
            
            centerDetailLabel,
            
            centerPhoneNumberStack,
            
            centerIntroductionStack,
            
            centerPictureLabel,
            centerImageView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        [
            navigationBar,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // 전체 뷰
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 뷰 고정 사이즈
        NSLayoutConstraint.activate([
            locationIcon.widthAnchor.constraint(equalToConstant: 24),
            locationIcon.heightAnchor.constraint(equalTo: locationIcon.widthAnchor),
            
            centerIntroductionField.heightAnchor.constraint(equalToConstant: 156),
        ])
        
        let contentGuide = scrollView.contentLayoutGuide
        scrollView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        scrollView.delaysContentTouches = false
        
        // 스크롤 뷰의 서브뷰
        NSLayoutConstraint.activate([
            
            centerNameLabel.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 25),
            centerNameLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            centerLocationStack.topAnchor.constraint(equalTo: centerNameLabel.bottomAnchor, constant: 12),
            centerLocationStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            divider.topAnchor.constraint(equalTo: centerLocationStack.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 8),
            
            centerDetailLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            centerDetailLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            centerPhoneNumberStack.topAnchor.constraint(equalTo: centerDetailLabel.bottomAnchor, constant: 20),
            centerPhoneNumberStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            centerPhoneNumberStack.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            centerIntroductionStack.topAnchor.constraint(equalTo: centerPhoneNumberStack.bottomAnchor, constant: 20),
            centerIntroductionStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            centerIntroductionStack.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            centerPictureLabel.topAnchor.constraint(equalTo: centerIntroductionStack.bottomAnchor, constant: 20),
            centerPictureLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            centerImageView.topAnchor.constraint(equalTo: centerPictureLabel.bottomAnchor, constant: 20),
            
            centerImageView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            centerImageView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            centerImageView.heightAnchor.constraint(equalToConstant: 250),
            centerImageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -38),
        ])
    }
    
    private func setObservable() {
    
    }
    
    func bind(viewModel: CenterProfileViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // input
        
        let bindFinished = PublishRelay<Void>()
        
        bindFinished
            .bind(to: viewModel.readyToFetch)
            .disposed(by: disposeBag)
        
        // 내 센터보기 상태인 경우(수정가능한 프로필 상태)
        if case .myProfile = viewModel.mode {
            
            profileEditButton
                .eventPublisher
                .bind(to: viewModel.editingButtonPressed)
                .disposed(by: disposeBag)
            
            editingCompleteButton
                .eventPublisher
                .bind(to: viewModel.editingFinishButtonPressed)
                .disposed(by: disposeBag)
            
            centerPhoneNumeberField.rx.text
                .compactMap { $0 }
                .bind(to: viewModel.editingPhoneNumber)
                .disposed(by: disposeBag)
            
            centerIntroductionField.rx.text
                .compactMap { $0 }
                .bind(to: viewModel.editingInstruction)
                .disposed(by: disposeBag)
            
            centerImageView
                .selectedImage
                .compactMap { $0 }
                .bind(to: viewModel.selectedImage)
                .disposed(by: disposeBag)
        }
        
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
            .centerPhoneNumber?
            .drive(centerPhoneNumeberField.rx.textString)
            .disposed(by: disposeBag)
        
        viewModel
            .centerIntroduction?
            .drive(onNext: { [weak self] introduceText in
                guard let self else { return }
                centerIntroductionLabel.textString = introduceText
                centerIntroductionLabel.isHidden = introduceText.isEmpty
                centerIntroductionTitleLabel.isHidden = introduceText.isEmpty
            })
            .disposed(by: disposeBag)
        viewModel
            .centerIntroduction?
            .drive(centerIntroductionField.rx.textString)
            .disposed(by: disposeBag)
        
        viewModel
            .displayingImage?
            .drive(centerImageView.displayingImage)
            .disposed(by: disposeBag)
        
        // MARK: Edit Mode
        if case .myProfile = viewModel.mode {
            
            viewModel
                .isEditingMode?
                .map { isEditing -> ImageSelectView.State in
                    isEditing ? .editing : .normal
                }
                .drive(centerImageView.state)
                .disposed(by: disposeBag)
            
            viewModel
                .isEditingMode?
                .drive { [weak self] in
                    guard let self else { return }
                    
                    centerPhoneNumeberField.isHidden = !$0
                    centerPhoneNumeberLabel.isHidden = $0
                    
                    if $0 {
                        centerIntroductionTitleLabel.isHidden = false
                    }
                    centerIntroductionField.isHidden = !$0
                    centerIntroductionLabel.isHidden = $0
                    
                    editingCompleteButton.isHidden = !$0
                    profileEditButton.isHidden = $0
                }
                .disposed(by: disposeBag)
            
            viewModel
                .editingValidation?
                .drive { _ in
                    // do something when editing success
                }
                .disposed(by: disposeBag)
        } else {
            // 수정 UI을 모두 끈다.
            centerPhoneNumeberField.isHidden = true
            centerIntroductionField.isHidden = true
            editingCompleteButton.isHidden = true
            profileEditButton.isHidden = true
            centerImageView.state.accept(.normal)
        }
        
        // 바인딩 종료
        bindFinished.accept(())
    }
}
