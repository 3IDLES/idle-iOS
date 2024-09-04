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

public typealias PostDetailDisplayingViewModelable = ApplicationDetailDisplayingVMable & CustomerInformationDisplayingVMable & WorkConditionDisplayingVMable

public protocol PostOverviewViewModelable:
    AnyObject,
    BaseViewModel,
    ApplicationDetailContentVMable,
    CustomerInformationContentVMable,
    CustomerRequirementContentVMable,
    WorkTimeAndPayContentVMable,
    AddressInputViewContentVMable,
    PostDetailDisplayingViewModelable
{
    
    var postOverviewCoordinator: PostOverviewCoordinator? { get set }
    
    /// 공고등록에 성공한 경우 해당 이벤트를 전달 받습니다
    var workerEmployCardVO: Driver<WorkerNativeEmployCardVO>? { get }
    
    /// 유효한 값을 가져옵니다.
    func fetchFromState()
    /// 수정중인 값을 API를 사용하여 전송할 값(State)에 반영합니다.
    func updateToState()
    
    var postEditButtonClicked: PublishRelay<Void> { get }
    var overViewExitButtonClicked: PublishRelay<Void> { get }
    var registerButtonClicked: PublishRelay<Void> { get }
    var overViewWillAppear: PublishRelay<Void> { get }
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
    
    let executeRegisterButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        button.label.textString = "확인했어요"
        return button
    }()
    
    // Overviews
    let workConditionOV = WorkConditionDisplayingView()
    let customerInfoOV = CustomerInformationDisplayingView()
    let applyInfoOverView = ApplicationDetailDisplayingView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
        setObservable()
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
            ("고객 정보", customerInfoOV),
            ("추가 지원 정보", applyInfoOverView),
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
        
        // 확인했어요
        let canEditRemiderLabel: IdleLabel = .init(typography: .Body3)
        canEditRemiderLabel.attrTextColor = DSKitAsset.Colors.gray300.color
        canEditRemiderLabel.textString = "공고 등록 후에도 공고 내용을 수정할 수 있어요. "
        
        // 카드 모양 조정
        let cardBackgroundView = UIView()
        cardBackgroundView.layer.borderWidth = 1
        cardBackgroundView.layer.cornerRadius = 12
        cardBackgroundView.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        cardBackgroundView.layoutMargins = .init(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        cardBackgroundView.addSubview(sampleCard)
        sampleCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sampleCard.topAnchor.constraint(equalTo: cardBackgroundView.layoutMarginsGuide.topAnchor),
            sampleCard.leftAnchor.constraint(equalTo: cardBackgroundView.layoutMarginsGuide.leftAnchor),
            sampleCard.rightAnchor.constraint(equalTo: cardBackgroundView.layoutMarginsGuide.rightAnchor),
            sampleCard.bottomAnchor.constraint(equalTo: cardBackgroundView.layoutMarginsGuide.bottomAnchor),
        ])
        
        // scroll view
        [
            titleLabel,
            subtitleLabel,
            cardBackgroundView,
            screenFoWorkerButton,
            overViewContentView,
            canEditRemiderLabel,
            executeRegisterButton
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            subtitleLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
                
            cardBackgroundView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            cardBackgroundView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            cardBackgroundView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            
            screenFoWorkerButton.topAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: 12),
            screenFoWorkerButton.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            overViewContentView.topAnchor.constraint(equalTo: screenFoWorkerButton.bottomAnchor, constant: 24),
            overViewContentView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            overViewContentView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            canEditRemiderLabel.topAnchor.constraint(equalTo: overViewContentView.bottomAnchor, constant: 32),
            canEditRemiderLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            executeRegisterButton.topAnchor.constraint(equalTo: canEditRemiderLabel.bottomAnchor, constant: 12),
            executeRegisterButton.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            executeRegisterButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            executeRegisterButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
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
        executeRegisterButton
            .rx.tap
            .subscribe { [weak self] _ in
                self?.view.isUserInteractionEnabled = false
            }
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: PostOverviewViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // 앞전까지 입력한 정보를 저장합니다.
        viewModel.updateToState()
        
        // 공고등록 요청
        executeRegisterButton
            .rx.tap
            .bind(to: viewModel.registerButtonClicked)
            .disposed(by: disposeBag)
        
        // 나가기
        backButton.rx.tap
            .bind(to: viewModel.overViewExitButtonClicked)
            .disposed(by: disposeBag)
        
        // 수정화면으로 이동
        postEditButton.eventPublisher
            .bind(to: viewModel.postEditButtonClicked)
            .disposed(by: disposeBag)
        
        // 화면이 등장할 때마다 유효한 상태를 불러옵니다.
        self.rx.viewWillAppear
            .map({ _ in })
            .bind(to: viewModel.overViewWillAppear)
            .disposed(by: disposeBag)
        
        // Ouptut
        workConditionOV.bind(viewModel: viewModel)
        customerInfoOV.bind(viewModel: viewModel)
        applyInfoOverView.bind(viewModel: viewModel)
        
        viewModel
            .workerEmployCardVO?
            .drive(onNext: { [sampleCard] vo in
                sampleCard.bind(ro: .create(vo: vo))
            })
            .disposed(by: disposeBag)
    }
}

