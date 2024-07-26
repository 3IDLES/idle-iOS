//
//  RegisterCenterInfoVC.swift
//  AuthFeature
//
//  Created by choijunios on 7/26/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

enum RegisterCenterInfoPage: Int, CaseIterable {
    case nameAndPhoneNumber = 0
    case address = 1
    case imageAndIntroduction = 2
}

public protocol RegisterCenterInfoViewModelable {
    
}


public class RegisterCenterInfoVC: UIViewController {
    
    // Init
    
    
    // Not init
    /// 현재 스크린의 넓이를 의미합니다.
    private var screenWidth: CGFloat {
        guard let screenWidth = view.window?.windowScene?.screen.bounds.width else {
            fatalError()
        }
        return screenWidth
    }

    private var pageViews: [UIView] = []
    
    var currentIndex: Int = -1
    
    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(
            navigationTitle: "센터 회원가입"
        )
        return bar
    }()
    lazy var statusBar: ProcessStatusBar = {
        
        let view = ProcessStatusBar(
            processCount: 3,
            startIndex: 0
        )
        return view
    }()
    
    // 하단 버튼
    private let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        
        return button
    }()
    
    let disposeBag = DisposeBag()

    public init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
    }
    
    /// 화면의 넓이를 안전하게 접근할 수 있는 시점, 화면 관련 속성들이 설정되어 있으므로 nil이 아닙니다.
    public override func viewDidAppear(_ animated: Bool) {
        setLayout()
        test()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        [
            navigationBar,
            statusBar,
            ctaButton,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            statusBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 7),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            ctaButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            ctaButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
            
        setPages()
        next(animated: false)
    }
    
    public func test() {
        
        ctaButton.eventPublisher.subscribe { [weak self] _ in
            self?.next()
        }
        .disposed(by: disposeBag)
        
        navigationBar.eventPublisher.subscribe { [weak self] _ in
            self?.prev()
        }
        .disposed(by: disposeBag)
    }
    
    private func setPages() {
        
        self.pageViews = RegisterCenterInfoPage.allCases.map { page in
            switch page {
            case .nameAndPhoneNumber:
                NameAndPhoneNumberView()
            case .address:
                AddressView()
            case .imageAndIntroduction:
                ImageAndIntroductionView()
            }
        }
        
        pageViews
            .enumerated()
            .forEach { index, subView in
                view.addSubview(subView)
                subView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    subView.topAnchor.constraint(equalTo: statusBar.bottomAnchor),
                    subView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    subView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    subView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
                ])
                
                subView.transform = .init(translationX: screenWidth, y: 0)
            }
    }
    
    private func next(animated: Bool = true) {
        
        if let nextIndex = RegisterCenterInfoPage(rawValue: currentIndex+1)?.rawValue {
            
            let prevView: UIView? = currentIndex != -1 ? pageViews[currentIndex] : nil
            let willShowView = pageViews[nextIndex]
            
            currentIndex = nextIndex
            
            UIView.animate(withDuration: animated ? 0.5 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView?.transform = .init(translationX: -screenWidth, y: 0)
                willShowView.transform = .identity
            }
        }
    }
    
    private func prev(animated: Bool = true) {
        if let nextIndex = RegisterCenterInfoPage(rawValue: currentIndex-1)?.rawValue {
            
            let prevView = pageViews[currentIndex]
            let willShowView = pageViews[nextIndex]
            
            currentIndex = nextIndex
            
            UIView.animate(withDuration: animated ? 0.35 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView.transform = .init(translationX: screenWidth, y: 0)
                willShowView.transform = .identity
            }
        }
    }
    
    public func bind(viewModel vm: RegisterCenterInfoViewModelable) {
        
        
    }
}

extension RegisterCenterInfoVC {
    
    // MARK: CenterInfoView (이름 + 센터 연락처)
    class NameAndPhoneNumberView: UIView {
        
        // View
        private let processTitle: IdleLabel = {
            let label = IdleLabel(typography: .Heading2)
            label.textString = "센터 정보를 입력해주세요."
            label.textAlignment = .left
            return label
        }()
        
        
        let nameField: IFType2 = {
            let field = IFType2(
                titleLabelText: "이름",
                placeHolderText: "센터 이름을 입력해주세요."
            )
            return field
        }()
        
        let phoneNumberField: IFType2 = {
            let field = IFType2(
                titleLabelText: "센터 연락처",
                placeHolderText: "지원자들의 연락을 받을 번호를 입력해주세요."
            )
            return field
        }()
        
        init() {
            super.init(frame: .zero)
            setAppearance()
            setLayout()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setAppearance() {
            
            self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
        }
        
        private func setLayout() {
            
            let inputStack = VStack(
                [
                    nameField,
                    phoneNumberField
                ],
                spacing: 28,
                alignment: .fill
            )
            
            [
                processTitle,
                inputStack
            ].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
            }
            
            NSLayoutConstraint.activate([
                
                processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
                processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
                processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
                
                inputStack.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
                inputStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
                inputStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ])
        }
        
        public func bind(viewModel vm: RegisterCenterInfoViewModelable) {
            
            
        }
    }
    
    // MARK: 센터주소 (도로명, 지번주소 + 상세주소)
    class AddressView: UIView {
        
        // View
        private let processTitle: IdleLabel = {
            let label = IdleLabel(typography: .Heading2)
            label.textString = "센터 주소 정보를 입력해주세요."
            label.textAlignment = .left
            return label
        }()
        
        let nameField: IFType2 = {
            let field = IFType2(
                titleLabelText: "도로명주소",
                placeHolderText: "도로명 주소를 입력해주세요."
            )
            return field
        }()
        
        let phoneNumberField: IFType2 = {
            let field = IFType2(
                titleLabelText: "상세 주소",
                placeHolderText: "상세 주소를 입력해주세요. (예: 2층 204호)"
            )
            return field
        }()
        
        init() {
            super.init(frame: .zero)
            setAppearance()
            setLayout()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setAppearance() {
            
            self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
        }
        
        private func setLayout() {
            
            let inputStack = VStack(
                [
                    nameField,
                    phoneNumberField
                ],
                spacing: 28,
                alignment: .fill
            )
            
            [
                processTitle,
                inputStack
            ].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
            }
            
            NSLayoutConstraint.activate([
                
                processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
                processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
                processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
                
                inputStack.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
                inputStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
                inputStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ])
        }
        
        public func bind(viewModel vm: RegisterCenterInfoViewModelable) {
            
            
        }
    }
 
    // MARK: 센터 소개 (프로필 사진 + 센터소개)
    class ImageAndIntroductionView: UIView {
        
        // View
        private let processTitle: IdleLabel = {
            let label = IdleLabel(typography: .Heading2)
            label.textString = "우리 센터를 소개해주세요!"
            label.textAlignment = .left
            return label
        }()
        private let subTitle: IdleLabel = {
            let label = IdleLabel(typography: .Body3)
            label.textString = "센터 소개글을 작성하면 보호사 매칭 성공률이 높아져요."
            label.attrTextColor = DSKitAsset.Colors.gray300.color
            label.textAlignment = .left
            return label
        }()
        
        /// 센터 소개를 수정하는 텍스트 필드
        private let centerIntroductionField: MultiLineTextField = {
            let textView = MultiLineTextField(
                typography: .Body3,
                placeholderText: "추가적으로 요구사항이 있다면 작성해주세요."
            )
            return textView
        }()
        
        private let centerImageView: ImageSelectView = {
            let view = ImageSelectView(state: .editing)
            return view
        }()
        
        init() {
            super.init(frame: .zero)
            setAppearance()
            setLayout()
        }
        required init?(coder: NSCoder) { fatalError() }
        
        private func setAppearance() { }
        
        private func setLayout() {
            
            let inputStackContents = [
                ("센터 소개", centerIntroductionField),
                ("센터 사진", centerImageView),
            ].map { (title: String, view: UIView) in
                
                let label = IdleLabel(typography: .Subtitle4)
                label.textString = title
                label.attrTextColor = DSKitAsset.Colors.gray500.color
                label.textAlignment = .left
                
                view.translatesAutoresizingMaskIntoConstraints = false
                
                return VStack(
                    [
                        label,
                        view
                    ],
                    spacing: 8,
                    alignment: .fill
                )
            }
            
            NSLayoutConstraint.activate([
            
                centerIntroductionField.heightAnchor.constraint(equalToConstant: 156),
                centerImageView.heightAnchor.constraint(equalToConstant: 254),
            ])
            
            let inputStack = VStack(
                inputStackContents,
                spacing: 20,
                alignment: .fill
            )
            
            
            let scrollView = UIScrollView()
            [
                processTitle,
                subTitle,
                inputStack
            ].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview($0)
            }
            let cg = scrollView.contentLayoutGuide
            scrollView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
            NSLayoutConstraint.activate([
                
                processTitle.topAnchor.constraint(equalTo: cg.topAnchor, constant: 32),
                processTitle.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
                processTitle.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
                
                subTitle.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 6),
                subTitle.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
                subTitle.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
                
                inputStack.topAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 32),
                inputStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
                inputStack.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
                inputStack.bottomAnchor.constraint(equalTo: cg.bottomAnchor, constant: -24),
            ])
            
            [
                scrollView
            ].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview($0)
            }
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: self.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
        
        public func bind(viewModel vm: RegisterCenterInfoViewModelable) {
            
            
        }
    }
}
