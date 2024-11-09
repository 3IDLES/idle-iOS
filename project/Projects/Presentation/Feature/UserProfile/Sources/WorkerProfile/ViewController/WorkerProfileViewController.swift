//
//  WorkerProfileViewController.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import DSKit
import Domain
import BaseFeature


import RxSwift
import RxCocoa

class WorkerProfileViewController: BaseViewController {
    
    // 네비게이션 바
    lazy var navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(titleText: "", innerViews: [profileEditButton])
        return bar
    }()
    
    // 수정하기 버튼
    let profileEditButton: TextButtonType2 = {
        let button = TextButtonType2(labelText: "수정하기")
        
        button.label.typography = .Body3
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        button.layoutMargins = .init(top: 5.5, left:12, bottom: 5.5, right: 12)
        button.layer.cornerRadius = 16
        button.isHidden = true
        return button
    }()
    
    // 프로필 이미지
    let profileImageContainer: UIImageView = {
        
        let view = UIImageView()
        view.backgroundColor = DSKitAsset.Colors.orange100.color
        view.layer.cornerRadius = 48
        view.clipsToBounds = true
        view.image = DSKitAsset.Icons.workerProfilePlaceholder.image
        view.contentMode = .scaleAspectFit

        return view
    }()
    let workerProfileImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 48
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    // 즐겨찾기 버튼
//    let starButton: IconWithColorStateButton = {
//        let button = IconWithColorStateButton(
//            representImage: DSKitAsset.Icons.subscribeStar.image,
//            normalColor: DSKitAsset.Colors.gray200.color,
//            accentColor: DSKitAsset.Colors.orange300.color
//        )
//        return button
//    }()
    
    // 구인중 / 휴식중
    let workingTag: TagLabel = {
       let label = TagLabel(
        text: "",
        typography: .caption,
        textColor: DSKitAsset.Colors.orange500.color,
        backgroundColor: DSKitAsset.Colors.orange100.color
       )
        return label
    }()
    
    // 성함(Label)
    let nameTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle3)
        label.textString = "요양보호사"
        return label
    }()
    let nameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        return label
    }()
    
    // 나이(Label + Content)
    let ageTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textString = "나이"
        return label
    }()
    let ageLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    
    
    // 성별(Label + Content)
    let genderTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textString = "성별"
        return label
    }()
    let genderLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    
    // 경력(Label + Content)
    let expTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textString = "경력"
        return label
    }()
    let expLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    
    // 통화하기 버튼
    // 통화하기, 채팅하기
    lazy var contactButtonContainer: HStack = .init(
        [phoneCallButton],
        spacing: 8,
        distribution: .fillEqually
    )
    let phoneCallButton: IdleSecondaryButton = {
        let button = IdleSecondaryButton(level: .medium)
        button.label.textString = "통화하기"
        return button
    }()
    
    // MARK: 상세정보
    
    // 주소(Label + Content)
    let addressTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textString = "주소"
        return label
    }()
    let addressLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.numberOfLines = 0
        return label
    }()
    
    // 한줄 소개(Label + Content)
    let introductionTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textString = "한줄 소개"
        return label
    }()
    let introductionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.numberOfLines = 0
        return label
    }()
    
    // 특기(Label)
    let abilityTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        label.textString = "특기"
        return label
    }()
    let abilityLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.numberOfLines = 0
        return label
    }()
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setApearance()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setApearance() {
        view.backgroundColor = DSKitAsset.Colors.gray050.color
    }
    
    private func setAutoLayout() {
        
        // 흑색 바탕
        let grayBackgrounnd = UIView()
        grayBackgrounnd.backgroundColor = DSKitAsset.Colors.gray050.color
        
        // 프로필 이미지
        profileImageContainer.addSubview(workerProfileImage)
        workerProfileImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            workerProfileImage.topAnchor.constraint(equalTo: profileImageContainer.topAnchor),
            workerProfileImage.leadingAnchor.constraint(equalTo: profileImageContainer.leadingAnchor),
            workerProfileImage.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor),
            workerProfileImage.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor),
        ])
        
        // 구직태그 + 이름 스택
        let nameStack = HStack(
            [
                nameLabel,
                nameTitleLabel
            ],
            spacing: 4,
            alignment: .center
        )
        let tagNameStack = VStack(
            [
                workingTag,
                nameStack
            ],
            alignment: .center
        )
        
        // 요양보호사 인적 정보
        let humanInfoStack = HStack([], alignment: .center)
        let humanInfoStackInfoList = [
            (ageTitleLabel, ageLabel),
            (genderTitleLabel, genderLabel),
            (expTitleLabel, expLabel),
        ]
            
        humanInfoStackInfoList
            .map { (title, content) in
            HStack(
                [
                    title,
                    content
                ],
                spacing: 4
            )
        }
        .enumerated()
        .forEach { (index, element) in
            
            humanInfoStack.addArrangedSubview(element)
            
            if index != humanInfoStackInfoList.count-1 {
                let divider = StickDivider(dividerWidth: 1, leftPadding: 8, rightPadding: 7)
                divider.backgroundColor = DSKitAsset.Colors.gray100.color
                
                humanInfoStack.addArrangedSubview(divider)
                
                divider.topAnchor.constraint(equalTo: humanInfoStack.topAnchor, constant: 2.5).isActive = true
                divider.bottomAnchor.constraint(equalTo: humanInfoStack.bottomAnchor, constant: -2.5).isActive = true
            }
        }
        
        // 요양보호사 구직정보
        let employeeInfoTitleLabel = IdleLabel(typography: .Subtitle1)
        employeeInfoTitleLabel.textString = "상세 정보"
        employeeInfoTitleLabel.textAlignment = .left
        
        let employeeInfoStack = VStack(
            [
                (addressTitleLabel, addressLabel),
                (introductionTitleLabel, introductionLabel),
                (abilityTitleLabel, abilityLabel),
            ]
                .map { (title, content) in
                return VStack(
                    [
                        title,
                        content
                    ],
                    spacing: 6,
                    alignment: .leading
                )
            },
            spacing: 28,
            alignment: .leading)

        let contentView = UIView()
        contentView.backgroundColor = DSKitAsset.Colors.gray0.color
        contentView.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 54,
            right: 20
        )
        
        // MARK: Divider
        // 요양보호사 인적정보 / 요양보호사 구직정보 디바이더
        let divider = Spacer(height: 8)
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        let contactButtonsAndDivider = VStack(
            [
                HStack([
                    Spacer(width: 36),
                    contactButtonContainer,
                    Spacer(width: 36)
                ]),
                divider
            ],
            spacing: 24,
            alignment: .fill
        )
        
        [
            grayBackgrounnd,
            profileImageContainer,
//            starButton,
            tagNameStack,
            humanInfoStack,
            contactButtonsAndDivider,
            employeeInfoTitleLabel,
            employeeInfoStack
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
                
        NSLayoutConstraint.activate([
            
            grayBackgrounnd.topAnchor.constraint(equalTo: contentView.topAnchor),
            grayBackgrounnd.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            grayBackgrounnd.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            grayBackgrounnd.heightAnchor.constraint(equalToConstant: 80),
            
            profileImageContainer.widthAnchor.constraint(equalToConstant: 96),
            profileImageContainer.heightAnchor.constraint(equalTo: profileImageContainer.widthAnchor),
            profileImageContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageContainer.centerYAnchor.constraint(equalTo: grayBackgrounnd.bottomAnchor),
            
//            starButton.widthAnchor.constraint(equalToConstant: 24),
//            starButton.heightAnchor.constraint(equalTo: starButton.widthAnchor),
//            starButton.topAnchor.constraint(equalTo: grayBackgrounnd.bottomAnchor, constant: 20),
//            starButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            
            tagNameStack.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 16),
            tagNameStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            humanInfoStack.topAnchor.constraint(equalTo: tagNameStack.bottomAnchor, constant: 2),
            humanInfoStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            contactButtonsAndDivider.topAnchor.constraint(equalTo: humanInfoStack.bottomAnchor, constant: 24),
            contactButtonsAndDivider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contactButtonsAndDivider.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            employeeInfoTitleLabel.topAnchor.constraint(equalTo: contactButtonsAndDivider.bottomAnchor, constant: 24),
            employeeInfoTitleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            
            employeeInfoStack.topAnchor.constraint(equalTo: employeeInfoTitleLabel.bottomAnchor, constant: 20),
            employeeInfoStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            employeeInfoStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            employeeInfoStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
        ])
        
        
        [
            navigationBar,
            scrollView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        navigationBar
            .backButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    /// 다른 프로필 확인용 바인딩 입니다.
    func bind(_ viewModel: OtherWorkerProfileViewModelable) {
        bind(viewModel as WorkerProfileViewModelable)
        
        phoneCallButton
            .rx.tap
            .bind(to: viewModel.phoneCallButtonClicked)
            .disposed(by: disposeBag)
    }
    
    /// 내프로필 접속용 바인딩 입니다.
    func bind(_ viewModel: WorkerProfileEditViewModelable) {
        bind(viewModel as WorkerProfileViewModelable)
        
        // Edit button
        profileEditButton
            .eventPublisher
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.editButtonClicked)
            .disposed(by: disposeBag)
    }
    
    private func bind(_ viewModel: any WorkerProfileViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // Input
        navigationBar
            .backButton.rx.tap
            .bind(to: viewModel.exitButtonClicked)
            .disposed(by: disposeBag)
        
        self.rx
            .viewWillAppear
            .filter { $0 }
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)

        
        // Output
        viewModel
            .profileRenderObject?
            .drive(onNext: { [weak self] ro in
                
                guard let self else { return }
                
                // UI 업데이트
                navigationBar.titleLabel.textString = ro.navigationTitle
                profileEditButton.isHidden = !ro.showEditButton
                contactButtonContainer.isHidden = !ro.showContactButton
//                starButton.isHidden = !ro.showStarButton
                workingTag.textString = ro.stateText
                nameLabel.textString = ro.nameText
                ageLabel.textString = ro.ageText
                genderLabel.textString = ro.genderText
                expLabel.textString = ro.expText
                
                addressLabel.textString = ro.address
                introductionLabel.textString = ro.oneLineIntroduce
                abilityLabel.textString = ro.specialty
            })
            .disposed(by: disposeBag)
        
        viewModel
            .displayingImage?
            .drive(onNext: { [weak self] image in
                guard let self else { return }
                UIView.transition(with: view, duration: 0.2) {
                    self.workerProfileImage .image = image
                }
            })
            .disposed(by: disposeBag)
    }
    
    func cleanUp() {
        
    }
}



@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    WorkerProfileViewController()
}
