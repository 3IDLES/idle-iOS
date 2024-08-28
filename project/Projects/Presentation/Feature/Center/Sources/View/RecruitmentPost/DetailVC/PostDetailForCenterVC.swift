//
//  PostDetailForCenterVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/14/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class PostDetailForCenterVC: BaseViewController {
    
    // Init
    
    // Not init
    var viewModel: PostDetailViewModelable?
    
    // View
    let optionButton: UIButton = {
        let button = UIButton()
        let image = DSIcon.dot3Option.image
        button.setImage(image, for: .normal)
        button.tintColor = DSColor.gray400.color
        return button
    }()
    lazy var navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(titleText: "공고 상세 정보", innerViews: [optionButton])
        return bar
    }()
    
    let sampleCard: WorkerEmployCard = {
        let card = WorkerEmployCard()
        card.starButton.isHidden = true
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
    
    let checkApplicantButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        button.label.textString = ""
        return button
    }()
    
    // Overviews
    let workConditionOV = WorkConditionDisplayingView()
    let customerInfoOV = CustomerInformationDisplayingView()
    let applyInfoOverView = ApplicationDetailDisplayingView()
    
    
    // Observable
    private let disposeBag = DisposeBag()
    
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
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        let contentView = UIView()
        contentView.layoutMargins = .init(top: 24, left: 20, bottom: 16, right: 20)
        
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
            cardBackgroundView,
            screenFoWorkerButton,
            overViewContentView,
            canEditRemiderLabel,
            checkApplicantButton
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            cardBackgroundView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            cardBackgroundView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            cardBackgroundView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            
            screenFoWorkerButton.topAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: 12),
            screenFoWorkerButton.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            overViewContentView.topAnchor.constraint(equalTo: screenFoWorkerButton.bottomAnchor, constant: 24),
            overViewContentView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            overViewContentView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            canEditRemiderLabel.topAnchor.constraint(equalTo: overViewContentView.bottomAnchor, constant: 32),
            canEditRemiderLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            
            checkApplicantButton.topAnchor.constraint(equalTo: canEditRemiderLabel.bottomAnchor, constant: 12),
            checkApplicantButton.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            checkApplicantButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            checkApplicantButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        
        // main view
        [
            navigationBar,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
    }
    
    private func setObservable() {
        
    }
    
    public func bind(viewModel: PostDetailViewModelable) {
        
        self.viewModel = viewModel
        
        // Input
        // 지원공고자 확인 버튼 클릭
        checkApplicantButton
            .rx.tap
            .bind(to: viewModel.checkApplicationButtonClicked)
            .disposed(by: disposeBag)
        
        // 나가기
        navigationBar.backButton.rx.tap
            .bind(to: viewModel.exitButtonClicked)
            .disposed(by: disposeBag)
        
        // 옵션 버튼
        optionButton
            .rx.tap
            .bind(to: viewModel.optionButtonClicked)
            .disposed(by: disposeBag)
        
        // 요양보호사가 보는 화면 보기
        screenFoWorkerButton.rx.tap
            .bind(to: viewModel.showAsWorkerButtonClicked)
            .disposed(by: disposeBag)
        

        // 화면이 등장할 때마다 유효한 상태를 불러옵니다.
        self.rx.viewWillAppear
            .map({ _ in })
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        // Ouptut
        viewModel
            .applicantCountText?
            .drive(onNext: { [weak self] text in
                self?.checkApplicantButton.label.textString = text
            })
            .disposed(by: disposeBag)
        
        
        // 옵션 뷰
        viewModel
            .showOptionSheet?
            .drive(onNext: { [weak self] state in
                guard let self, let vm = self.viewModel else { return }
                var vc: IdleBottomSheetVC!
                switch state {
                case .onGoing:
                    let onGoingVC = OngoingPostOptionVC()
                    onGoingVC.bind(viewModel: vm)
                    vc = onGoingVC
                case .closed:
                    let closedVC = ClosedPostOptionVC()
                    closedVC.bind(viewModel: vm)
                    vc = closedVC
                }
                
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false)
            })
            .disposed(by: disposeBag)
        
        workConditionOV.bind(viewModel: viewModel)
        customerInfoOV.bind(viewModel: viewModel)
        applyInfoOverView.bind(viewModel: viewModel)
        
        viewModel
            .requestDetailFailure?
            .drive(onNext: { [weak self] alertVO in
                
                self?.showAlert(vo: alertVO, onClose: {
                    self?.viewModel?.exitButtonClicked.accept(())
                })
            })
            .disposed(by: disposeBag)
        
        viewModel
            .workerEmployCardVO?
            .drive(onNext: { [sampleCard] vo in
                sampleCard.bind(ro: .create(vo: vo))
            })
            .disposed(by: disposeBag)
    }
}

