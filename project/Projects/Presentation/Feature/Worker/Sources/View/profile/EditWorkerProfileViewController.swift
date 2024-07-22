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
    
    // 이름
    let nameInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "성함"
        )
        textView.textContainerInset = .init(top: 10, left: 16, bottom: 10, right: 24)
        textView.isScrollEnabled = false
        
        return textView
    }()
    
    // 성별
    let femaleButton: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: Gender.female.twoLetterKoreanWord,
            initial: .normal
        )
        return btn
    }()
    let maleButton: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: Gender.male.twoLetterKoreanWord,
            initial: .normal
        )
        return btn
    }()
    
    // 나이
    let ageInputField: IdleTextField = {
        let field = IdleTextField(typography: .Body2)
        field.keyboardType = .numberPad
        return field
    }()
    
    // 경력
    let expLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.attrTextColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let expEditButton: UIButton = {
        let btn = UIButton()
        btn.setImage(DSKitAsset.Icons.chevronDown.image, for: .normal)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    
    // 주소
    let addressInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "주소"
        )
        textView.textContainerInset = .init(top: 10, left: 16, bottom: 10, right: 24)
        textView.isScrollEnabled = false
        return textView
    }()
    
    // 한줄소개
    let introductionInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "소개"
        )
        textView.textContainerInset = .init(top: 10, left: 16, bottom: 10, right: 24)
        textView.isScrollEnabled = false
        return textView
    }()
    
    // 특기
    let abilityInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "특기"
        )
        textView.textContainerInset = .init(top: 12, left: 16, bottom: 16, right: 22)
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
        
        // 나이
        let ageInputContainer = HStack(
            [
               ageInputField,
               {
                   let label = IdleLabel(typography: .Body3)
                   label.textString = "세"
                   return label
               }()
            ],
            alignment: .center,
            distribution: .equalSpacing
        )
        let ageInputContainerBackground = {
            let view = UIView()
            view.backgroundColor = .clear
            view.layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 15.5)
            view.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 6.0
            return view
        }()
        ageInputContainerBackground.addSubview(ageInputContainer)
        ageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // 명시적 높이 지정
            ageInputContainer.heightAnchor.constraint(equalToConstant: 24),
            
            ageInputContainer.topAnchor.constraint(equalTo: ageInputContainerBackground.layoutMarginsGuide.topAnchor),
            ageInputContainer.bottomAnchor.constraint(equalTo: ageInputContainerBackground.layoutMarginsGuide.bottomAnchor),
            ageInputContainer.leadingAnchor.constraint(equalTo: ageInputContainerBackground.layoutMarginsGuide.leadingAnchor),
            ageInputContainer.trailingAnchor.constraint(equalTo: ageInputContainerBackground.layoutMarginsGuide.trailingAnchor),
        ])
        
        // 경력
        let expInputContainer = HStack(
            [
               expLabel,
               expEditButton
            ],
            alignment: .center,
            distribution: .equalSpacing
        )
        let expInputContainerBackground = {
            let view = UIView()
            view.backgroundColor = .clear
            view.layoutMargins = .init(top: 10, left: 16, bottom: 10, right: 15.5)
            view.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 6.0
            return view
        }()
        expInputContainerBackground.addSubview(expInputContainer)
        expInputContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // 명시적 높이 지정
            expInputContainer.heightAnchor.constraint(equalToConstant: 24),
            
            expInputContainer.topAnchor.constraint(equalTo: expInputContainerBackground.layoutMarginsGuide.topAnchor),
            expInputContainer.bottomAnchor.constraint(equalTo: expInputContainerBackground.layoutMarginsGuide.bottomAnchor),
            expInputContainer.leadingAnchor.constraint(equalTo: expInputContainerBackground.layoutMarginsGuide.leadingAnchor),
            expInputContainer.trailingAnchor.constraint(equalTo: expInputContainerBackground.layoutMarginsGuide.trailingAnchor),
        ])
 
        // 나이+경력
        let ageExpStack = HStack(
            [
                ("나이", ageInputContainerBackground),
                ("경력", expInputContainerBackground)
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
            }
            , spacing: 4,
            distribution: .fillEqually
        )
        
        // 성별
        let genderStack = VStack(
            [
                {
                    let label = IdleLabel(typography: .Subtitle4)
                    label.textString = "성별"
                    label.attrTextColor = DSKitAsset.Colors.gray300.color
                    return label
                }(),
                HStack(
                    [
                        femaleButton,
                        maleButton
                    ].map { btn in
                        NSLayoutConstraint.activate([
                            btn.widthAnchor.constraint(equalToConstant: 104),
                            btn.heightAnchor.constraint(equalToConstant: 44),
                        ])
                        return btn
                    },
                    spacing: 4
                )
            ],
            spacing: 6,
            alignment: .leading
        )
        
        // 이름
        let nameStack = VStack(
            [
                {
                    let label = IdleLabel(typography: .Subtitle4)
                    label.textString = "이름"
                    label.attrTextColor = DSKitAsset.Colors.gray300.color
                    label.textAlignment = .left
                    return label
                }(),
                nameInputField
            ],
            spacing: 6,
            alignment: .fill
        )
        
        // // 요양보호사 인적정보 / 요양보호사 구직정보 디바이더
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        // 주소 + 소개 + 특기
        let addressIntroductionAbilityStack = VStack(
            [
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
            nameStack,
            genderStack,
            ageExpStack,
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
            
            nameStack.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 19),
            nameStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            nameStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            genderStack.topAnchor.constraint(equalTo: nameStack.bottomAnchor, constant: 24),
            genderStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            genderStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ageExpStack.topAnchor.constraint(equalTo: genderStack.bottomAnchor, constant: 28),
            ageExpStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ageExpStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            divider.topAnchor.constraint(equalTo: ageExpStack.bottomAnchor, constant: 24),
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
