//
//  EditWorkerProfileViewController.swift
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
import BaseFeature


public class EditWorkerProfileViewController: DisposableViewController {
    
    // Navigation bar
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "내 프로필")
        return bar
    }()
    
    let editingCompleteButton: TextButtonType3 = {
        let btn = TextButtonType3(typography: .Subtitle2)
        btn.textString = "저장"
        btn.attrTextColor = DSKitAsset.Colors.orange500.color
        
        return btn
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
    let workerProfileDisplayingImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 48
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    let workerProfileImageEditButton: UIButton = {
        let btn = UIButton()
        btn.setImage(DSKitAsset.Icons.editPhoto.image, for: .normal)
        btn.imageView?.layer.borderColor = DSKitAsset.Colors.gray050.color.cgColor
        btn.imageView?.layer.cornerRadius = 16
        btn.imageView?.layer.borderWidth = 1
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    // 경력
    let experiencedSelectButton: ExpPicker = {
        let button = ExpPicker(placeholderText: "연차")
        
        button.textLabel.attrTextColor = DSKitAsset.Colors.gray500.color
        button.imageView.image = DSKitAsset.Icons.chevronDown.image
        button.imageView.tintColor = DSKitAsset.Colors.gray200.color
        
        return button
    }()
    
    // 주소
    let addressInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "주소"
        )
        textView.isScrollEnabled = false
        return textView
    }()
    
    // 한줄소개
    let introductionInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "소개"
        )
        textView.isScrollEnabled = false
        return textView
    }()
    
    // 특기
    let abilityInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "특기"
        )
        textView.isScrollEnabled = false
        return textView
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
    private func setApearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }
    
    private func setAutoLayout() {
        
        // 네비게이션 바
        let navigationStack = HStack([
            navigationBar,
            editingCompleteButton,
        ])
        navigationStack.distribution = .equalSpacing
        navigationStack.backgroundColor = .white
        
        let navigationStackBackground = UIView()
        navigationStackBackground.addSubview(navigationStack)
        navigationStack.translatesAutoresizingMaskIntoConstraints = false
        navigationStackBackground.backgroundColor = .white
        navigationStackBackground.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 28)
        NSLayoutConstraint.activate([
            navigationStack.topAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.topAnchor),
            navigationStack.leadingAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.leadingAnchor),
            navigationStack.trailingAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.trailingAnchor),
            navigationStack.bottomAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.bottomAnchor),
        ])
        
        // 프로필 뷰
        [
            workerProfileDisplayingImage
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            profileImageContainer.addSubview($0)
        }
        NSLayoutConstraint.activate([
            workerProfileDisplayingImage.topAnchor.constraint(equalTo: profileImageContainer.topAnchor),
            workerProfileDisplayingImage.leadingAnchor.constraint(equalTo: profileImageContainer.leadingAnchor),
            workerProfileDisplayingImage.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor),
            workerProfileDisplayingImage.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor),
        ])
        
        
        // // 요양보호사 인적정보 / 요양보호사 구직정보 디바이더
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        // 경력, 주소, 한줄소개, 특기
        let addressIntroductionAbilityStack = VStack(
            [
                ("경력", experiencedSelectButton),
                ("주소", addressInputField),
                ("한줄 소개", introductionInputField),
                ("특기", abilityInputField),
            ].map { (title, content) in
                VStack(
                    [
                        {
                            let label = IdleLabel(typography: .Subtitle4)
                            label.textString = title
                            label.attrTextColor = DSKitAsset.Colors.gray300.color
                            label.textAlignment = .left
                            return label
                        }(),
                        content
                    ],
                    spacing: 6,
                    alignment: .fill
                )
            },
            spacing: 28,
            alignment: .fill
        )
        
        // 컨트롤러 뷰 설정
        let scrollView = {
            let view = UIScrollView()
            // 발생한 터치가 스크롤인지 판단하지 않고 즉시 touchShouldBegin매서드를 호출한다.
            // true시 탭동작을 스크롤로 판단한다.
            view.delaysContentTouches = false
            return view
        }()
        
        let scrollViewContentGuide = scrollView.contentLayoutGuide
        
        [
            navigationStackBackground,
            scrollView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationStackBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            navigationStackBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationStackBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationStackBackground.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Scroll View
        [
            profileImageContainer,
            divider,
            addressIntroductionAbilityStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        scrollView.insertSubview(workerProfileImageEditButton, aboveSubview: profileImageContainer)
        workerProfileImageEditButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            workerProfileImageEditButton.widthAnchor.constraint(equalToConstant: 32),
            workerProfileImageEditButton.heightAnchor.constraint(equalTo: workerProfileImageEditButton.widthAnchor),
            workerProfileImageEditButton.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor),
            workerProfileImageEditButton.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor, constant: 7),
            
            profileImageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageContainer.topAnchor.constraint(equalTo: scrollViewContentGuide.topAnchor, constant: 40),
            
            divider.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 24),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 8),
            
            addressIntroductionAbilityStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            addressIntroductionAbilityStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            addressIntroductionAbilityStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addressIntroductionAbilityStack.bottomAnchor.constraint(
                equalTo: scrollViewContentGuide.bottomAnchor, constant: -28.37),
            
            abilityInputField.heightAnchor.constraint(equalToConstant: 156)
        ])
        
    }
    
    private func setObservable() {
        
        navigationBar
            .eventPublisher
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    public func cleanUp() {
        
    }
    
}
