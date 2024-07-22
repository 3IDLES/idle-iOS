//
//  WorkerProfileViewController.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity

public protocol WorkerProfileViewModelable where Input: WorkerProfileInputable, Output: WorkerProfileOutputable {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output? { get }
}

public protocol WorkerProfileInputable: AnyObject {
    var viewWillAppear: PublishRelay<Void> { get }
}

public protocol WorkerProfileOutputable: AnyObject {
    
    var profileVO: Driver<WorkerProfileVO> { get }
    var displayingImage: Driver<UIImage?> { get }
}

public class WorkerProfileViewController: DisposableViewController {
    
    // 네비게이션 바
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "내 프로필")
        return bar
    }()
    
    // 수정하기 버튼
    let profileEditButton: TextButtonType2 = {
        let button = TextButtonType2(labelText: "수정하기")
        
        button.label.typography = .Body3
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        button.layoutMargins = .init(top: 5.5, left:12, bottom: 5.5, right: 12)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // 프로필 이미지
    let profileImageContainer: UIView = {
        
        let view = UIView()
        view.backgroundColor = DSKitAsset.Colors.orange100.color
        view.layer.cornerRadius = 48
        view.clipsToBounds = true
        
        let imageView = DSKitAsset.Icons.workerProfilePlaceholder.image.toView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -29),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -27),
        ])

        return view
    }()
    let workerProfileImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 48
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    // 구인중 / 휴식중
    let workingTag: TagLabel = {
       let label = TagLabel(
        text: "구직중",
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
    
    let disposeBag = DisposeBag()
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setApearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }
    
    func setAutoLayout() {
        
        // 상단 네비게이션바 세팅
        let navigationStack = HStack([
            navigationBar,
            profileEditButton,
        ])
        navigationStack.distribution = .equalSpacing
        navigationStack.backgroundColor = .clear
        
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
            alignment: .bottom
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
        
        // 요양보호사 인적정보 / 요양보호사 구직정보 디바이더
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        
        // 요양보호사 구직정보
        
        let employeeInfoStack = VStack(
            [],
            spacing: 28,
            alignment: .leading)
        let employeeInfoStackInfoList = [
            (addressTitleLabel, addressLabel),
            (introductionTitleLabel, introductionLabel),
            (abilityTitleLabel, abilityLabel),
        ]
        
        employeeInfoStackInfoList
            .map { (title, content) in
            return VStack(
                [
                    title,
                    content
                ],
                spacing: 6,
                alignment: .leading
            )
        }
        .forEach {
            employeeInfoStack.addArrangedSubview($0)
        }

        // view hierarchy
        [
            grayBackgrounnd,
            navigationStack,
            profileImageContainer,
            tagNameStack,
            humanInfoStack,
            divider,
            employeeInfoStack
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        grayBackgrounnd.layer.zPosition = 0.0
        navigationStack.layer.zPosition = 1.0
                
        NSLayoutConstraint.activate([
            
            grayBackgrounnd.topAnchor.constraint(equalTo: view.topAnchor),
            grayBackgrounnd.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            grayBackgrounnd.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grayBackgrounnd.heightAnchor.constraint(equalToConstant: 196),
            
            navigationStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            navigationStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            profileImageContainer.widthAnchor.constraint(equalToConstant: 96),
            profileImageContainer.heightAnchor.constraint(equalTo: profileImageContainer.widthAnchor),
            profileImageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageContainer.centerYAnchor.constraint(equalTo: grayBackgrounnd.bottomAnchor),
            
            tagNameStack.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 16),
            tagNameStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            humanInfoStack.topAnchor.constraint(equalTo: tagNameStack.bottomAnchor, constant: 16),
            humanInfoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            divider.topAnchor.constraint(equalTo: humanInfoStack.bottomAnchor, constant: 24),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 8),
            
            employeeInfoStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            employeeInfoStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            employeeInfoStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    func setObservable() {
        
        
    }
    
    
    public func bind(_ viewModel: any WorkerProfileViewModelable) {
        
        let input = viewModel.input
           
        guard let output = viewModel.output else { fatalError() }
        
        output
            .profileVO
            .drive(onNext: { [weak self] vo in
                
                guard let self else { return }
                
                // UI 업데이트
                workingTag.isHidden = !vo.isLookingForJob
                nameLabel.textString = vo.nameText
                ageLabel.textString = vo.ageText
                genderLabel.textString = vo.genderText
                expLabel.textString = vo.expYearText
                addressLabel.textString = vo.addressText
                introductionLabel.textString = vo.introductionText
                abilityLabel.textString = vo.abilitiesText
            })
            .disposed(by: disposeBag)
        
        output
            .displayingImage
            .drive(workerProfileImage.rx.image)
            .disposed(by: disposeBag)
        
        self.rx
            .viewWillAppear
            .filter { $0 }
            .map { _ in () }
            .bind(to: input.viewWillAppear)
            .disposed(by: disposeBag)
        
    }
    
    public func cleanUp() {
        
    }
}
