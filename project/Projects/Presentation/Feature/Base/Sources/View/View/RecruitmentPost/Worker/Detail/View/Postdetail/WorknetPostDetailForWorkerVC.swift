//
//  WorknetPostDetailForWorkerVC.swift
//  BaseFeature
//
//  Created by choijunios on 9/6/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class WorknetPostDetailForWorkerVC: BaseViewController {
    
    // Init
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(innerViews: [])
        bar.titleLabel.textString = "공고 정보"
        return bar
    }()
    
    // 구인공고 카드
    let cardView: WorkerWorknetEmployCard = {
        let view = WorkerWorknetEmployCard()
        return view
    }()
    
    // 근무 장소(타이틀/설명1/걸어서~/지도)
    let workPlaceAndWorkerLocationView = WorkPlaceAndWorkerLocationView()
    
    // 워크넷 링크
    var workNetPostLink: URL?
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
        setLayout()
        setObservable()
    }
    
    // 모집 요강
    let recruitmentDetailTextView: MultiLineTextField = {
        let field = MultiLineTextField(typography: .Body3)
        field.isScrollEnabled = false
        field.isUserInteractionEnabled = false
        return field
    }()
    
    // 근무 조건
    let workShapeLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    let workTimeLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    let paymentConditionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    let workAddressLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    
    
    // 전형방법
    let applyDeadlineLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    let applyMethodLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    let submitMethodLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    let submitDocsLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.numberOfLines = 0
        return label
    }()
    
    
    // 기관 정보
    let centerInfoCard: CenterInfoCardView = {
        let view = CenterInfoCardView()
        view.isUserInteractionEnabled = false
        view.chevronLeftImage.isHidden = true
        return view
    }()
    
    // 워크넷 링크
    let worknetLinkCard: CenterInfoCardView = {
        let view = CenterInfoCardView()
        view.locationImageView.isHidden = true
        return view
    }()
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public func bind(viewModel: WorknetPostDetailForWorkerViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .postDetail?
            .drive(onNext: {
                [weak self] detailVO in
                
                guard let self else { return }
                
                // card
                let cardRO: WorkerWorknetEmployCardRO = .create(vo: detailVO)
                cardView.applyRO(ro: cardRO)
                
                // 모집요강
                recruitmentDetailTextView.textString = detailVO.content
                recruitmentDetailTextView.sizeToFit()
                
                // 근무조건
                workShapeLabel.textString = detailVO.workingSchedule
                workTimeLabel.textString = detailVO.workingTime
                paymentConditionLabel.textString = detailVO.payInfo
                workAddressLabel.textString = detailVO.clientAddress
                
                // 전형방법
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let applyDeadlineText = dateFormatter.string(from: detailVO.applyDeadline)
                applyDeadlineLabel.textString = applyDeadlineText
                applyMethodLabel.textString = detailVO.applyMethod
                submitMethodLabel.textString = detailVO.recruitmentProcess
                submitDocsLabel.textString = detailVO.requiredDocumentation
                
                // 기관정보
                centerInfoCard.bind(
                    nameText: detailVO.centerName,
                    locationText: detailVO.centerAddress
                )
                
                // 워크넷 링크
                worknetLinkCard.bind(
                    nameText: detailVO.title,
                    locationText: detailVO.jobPostingUrl
                )
                workNetPostLink = URL(string: detailVO.jobPostingUrl)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .starButtonRequestResult?
            .drive(onNext: { [weak self] isSuccess in
                
                guard let self else { return }
                
                if isSuccess {
                    cardView.starButton.toggle()
                }
            })
            .disposed(by: disposeBag)
        
        // 위치정보
        if let locationInfo = viewModel.locationInfo?.asObservable().share() {
            
            locationInfo
                .subscribe(onNext: {
                    [weak self] info in
                    // 위치정보 전달
                    self?.workPlaceAndWorkerLocationView.bind(locationRO: info)
                })
                .disposed(by: disposeBag)
            
            // 지도화면 클릭시
            workPlaceAndWorkerLocationView.mapViewBackGround
                .rx.tap
                .withLatestFrom(locationInfo)
                .subscribe { [weak self] locationInfo in
                    let fullMapVC = WorkPlaceAndWorkerLocationFullVC()
                    fullMapVC.bind(locationRO: locationInfo)
                    self?.navigationController?.pushViewController(fullMapVC, animated: true)
                }
                .disposed(by: disposeBag)
        }
        
        // Input
        self.rx.viewWillAppear
            .map({ _ in  })
            .bind(to: viewModel.requestRefresh)
            .disposed(by: disposeBag)
        
        cardView.starButton
            .onTapEvent
            .map { state in
                // normal인 경우 true / 즐겨찾기 요청
                state == .normal
            }
            .bind(to: viewModel.starButtonClicked)
            .disposed(by: disposeBag)
        
        // 뒤로가기 버튼
        navigationBar.backButton
            .rx.tap
            .bind(to: viewModel.backButtonClicked)
            .disposed(by: disposeBag)
    }
    
    func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    func setLayout() {
        
        // 근무조건
        let workConditionComponentStackList = [
            ("근무 형태", workShapeLabel),
            ("근무 시간", workTimeLabel),
            ("임김 조건", paymentConditionLabel),
            ("근무 주소", workAddressLabel),
        ].map { (keyText, valueLabel) in
            
            let keyLabel = IdleLabel(typography: .Body2)
            keyLabel.attrTextColor = DSColor.gray300.color
            keyLabel.textString = keyText
            keyLabel.textAlignment = .left
            
            return HStack([keyLabel, valueLabel], spacing: 32, alignment: .top)
        }
        
        let workConditionStack: VStack = .init(workConditionComponentStackList, spacing: 8, alignment: .leading)
        
        // 전형방법
        let applyMethodComponentStackList = [
            ("접수 마감일", applyDeadlineLabel),
            ("전형 방법", applyMethodLabel),
            ("접수 방법", submitMethodLabel),
            ("제출 서류", submitDocsLabel),
        ].map { (keyText, valueLabel) in
            
            let keyLabel = IdleLabel(typography: .Body2)
            keyLabel.attrTextColor = DSColor.gray300.color
            keyLabel.textString = keyText
            let labelWidth = keyLabel.intrinsicContentSize.width
            let spacing = 114 - labelWidth
            
            return HStack([keyLabel, valueLabel], spacing: spacing, alignment: .top)
        }
        
        let applyMethodComponentStack: VStack = .init(applyMethodComponentStackList, spacing: 8, alignment: .leading)
        
        let scrollView = UIScrollView()
        let scvContentGuide = scrollView.contentLayoutGuide
        let scvFrameGuide = scrollView.frameLayoutGuide
        
        let viewList = [
            
            cardView,
            
            workPlaceAndWorkerLocationView,
            
            VStack([
                makeTitleLabel(text: "모집요강"),
                recruitmentDetailTextView
            ], spacing: 20, alignment: .fill),
            
            VStack([
                makeTitleLabel(text: "근무 조건"),
                workConditionStack
            ], spacing: 20, alignment: .fill),
            
            VStack([
                makeTitleLabel(text: "전형 방법"),
                applyMethodComponentStack
            ], spacing: 20, alignment: .fill),
            
            VStack([
                makeTitleLabel(text: "기관 정보"),
                centerInfoCard
            ], spacing: 20, alignment: .fill),
            
            VStack([
                makeTitleLabel(text: "워크넷 링크"),
                worknetLinkCard
            ], spacing: 20, alignment: .fill),
            
        ].map { containerView in
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = DSColor.gray0.color
            backgroundView.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: backgroundView.layoutMarginsGuide.topAnchor),
                containerView.leftAnchor.constraint(equalTo: backgroundView.layoutMarginsGuide.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: backgroundView.layoutMarginsGuide.rightAnchor),
                containerView.bottomAnchor.constraint(equalTo: backgroundView.layoutMarginsGuide.bottomAnchor),
            ])
            return backgroundView
        }
        
        let scvContentStack = VStack(viewList, spacing: 8, alignment: .fill)
        scvContentStack.backgroundColor = DSColor.gray050.color
        
        scvContentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scvContentStack)
        
        NSLayoutConstraint.activate([
            scvContentStack.topAnchor.constraint(equalTo: scvContentGuide.topAnchor),
            scvContentStack.leftAnchor.constraint(equalTo: scvContentGuide.leftAnchor),
            scvContentStack.rightAnchor.constraint(equalTo: scvContentGuide.rightAnchor),
            scvContentStack.bottomAnchor.constraint(equalTo: scvContentGuide.bottomAnchor),
            
            scvContentStack.widthAnchor.constraint(equalTo: scvFrameGuide.widthAnchor)
        ])
        
        // MARK: view
        [
            navigationBar,
            scrollView
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
    
    func setObservable() {
        
        worknetLinkCard
            .rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self, let url = self.workNetPostLink else { return }
                
                _ = openDeepLink(url: url)
            })
            .disposed(by: disposeBag)
    }
    
    private func openDeepLink(url: URL) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
    
    func makeTitleLabel(text: String) -> IdleLabel {
        let label = IdleLabel(typography: .Subtitle1)
        label.textAlignment = .left
        label.textString = text
        return label
    }
}
