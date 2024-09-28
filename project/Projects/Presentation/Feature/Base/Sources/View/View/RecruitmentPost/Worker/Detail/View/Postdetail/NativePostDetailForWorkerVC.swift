//
//  NativePostDetailForWorkerVC.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import UIKit
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

/// 센토도 요양보호사가 보는 공고화면을 볼 수 있기 때문에 해당뷰를 BaseFeature에 구현하였습니다.
public class NativePostDetailForWorkerVC: BaseViewController {

    // Init
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(innerViews: [])
        bar.titleLabel.textString = "공고 정보"
        return bar
    }()
    
    let contentView = PostDetailForWorkerContentView()
    
    // 하단 버튼
    let csButton: IdleSecondaryButton = {
        let btn = IdleSecondaryButton(level: .medium)
        btn.label.textString = "문의하기"
        return btn
    }()
    let applyButton: IdlePrimaryButton = {
        let btn = IdlePrimaryButton(level: .medium)
        btn.label.textString = "지원하기"
        btn.setEnabled(false)
        return btn
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        contentView.layoutMargins = .init(top: 24, left: 0, bottom: 16, right: 0)
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
        ])
        
        // Button
        let buttonStack = HStack([csButton, applyButton], spacing: 8, distribution: .fillEqually)
        
        
        // main view
        [
            navigationBar,
            scrollView,
            buttonStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -12),
            
            buttonStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    public func bind(viewModel: NativePostDetailForWorkerViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .postForWorkerBundle?
            .drive(onNext: {
                [weak self] bundle in
                guard let self else { return }
                
                // 상단 구인공고 카드
                let cardVO: WorkerNativeEmployCardVO = .create(bundle: bundle)
                let cardRO: WorkerNativeEmployCardRO = .create(vo: cardVO)
                
                contentView.cardView.bind(ro: cardRO)
                
                if bundle.applyDate != nil {
                    // 지원한 공고인 경우
                    applyButton.setEnabled(false)
                } else {
                    // 지원하지 않은 공고인 경우
                    applyButton.setEnabled(true)
                }
                
                // 근무 조건
                contentView.workConditionView.bind(
                    workTimeAndPayStateObject: bundle.workTimeAndPay,
                    addressInputStateObject: bundle.addressInfo
                )
                
                // 고객 정보
                contentView.customerInfoView.bind(
                    customerInformationStateObject: bundle.customerInformation,
                    customerRequirementStateObject: bundle.customerRequirement
                )
                
                // 추가 지원 정보
                contentView.applicationDetailView.bind(
                    applicationDetailStateObject: bundle.applicationDetail
                )
                
                // 센터 정보 카드
                let centerInfo = bundle.centerInfo
                contentView.centerInfoCard.bind(
                    nameText: centerInfo.centerName,
                    locationText: centerInfo.centerRoadAddress
                )
                
            })
            .disposed(by: disposeBag)
        
        if let locationInfo = viewModel.locationInfo?.asObservable().share() {
            
            locationInfo
                .subscribe(onNext: {
                    [weak self] info in
                    // 위치정보 전달
                    self?.contentView.workPlaceAndWorkerLocationView.bind(locationRO: info)
                })
                .disposed(by: disposeBag)
            
            // 지도화면 클릭시
            contentView.workPlaceAndWorkerLocationView.mapViewBackGround
                .rx.tap
                .withLatestFrom(locationInfo)
                .subscribe { [weak self] locationInfo in
                    let fullMapVC = WorkPlaceAndWorkerLocationFullVC()
                    fullMapVC.bind(locationRO: locationInfo)
                    self?.navigationController?.pushViewController(fullMapVC, animated: true)
                }
                .disposed(by: disposeBag)
        }
        
        viewModel
            .idleAlertVM?
            .drive(onNext: { [weak self] vm in
                self?.showIdleModal(type: .orange, viewModel: vm)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .starButtonRequestResult?
            .drive(onNext: { [weak self] isSuccess in
                
                guard let self else { return }
                
                if isSuccess {
                    contentView.cardView.starButton.toggle()
                }
            })
            .disposed(by: disposeBag)
        
        // 문의하기 버튼
        if let centerInfo = viewModel.centerInfoForCS?.asObservable() {
            csButton.rx.tap
                .withLatestFrom(centerInfo.asObservable())
                .subscribe (onNext: { [weak self] info in
                    let vc = SelectCSTypeVC()
                    vc.phoneCSButton.bind(
                        nameText: info.name,
                        phoneNumberText: info.phoneNumber
                    )
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: false)
                })
                .disposed(by: disposeBag)
        }
        
        // 지원성공시 비활성화
        viewModel
            .applySuccess?
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.applyButton.setEnabled(false)
            })
            .disposed(by: disposeBag)
        
        // Input
        
        // viewWillAppear
        self.rx.viewWillAppear
            .map({ _ in  })
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        // 지원하기
        applyButton
            .rx.tap
            .bind(to: viewModel.applyButtonClicked)
            .disposed(by: disposeBag)
        
        // 즐겨 찾기 버튼
        contentView.cardView.starButton
            .onTapEvent
            .map { state in
                // normal인 경우 true / 즐겨찾기 요청
                state == .normal
            }
            .bind(to: viewModel.starButtonClicked)
            .disposed(by: disposeBag)
            
        
        // 센터 프로필 보기 버튼
        contentView.centerInfoCard
            .rx.tap
            .bind(to: viewModel.centerCardClicked)
            .disposed(by: disposeBag)
        
        // 뒤로가기 버튼
        navigationBar.backButton
            .rx.tap
            .bind(to: viewModel.backButtonClicked)
            .disposed(by: disposeBag)

    }
}

// MARK: PostDetailContentView
public class PostDetailForWorkerContentView: UIView {
    
    /// 구인공고 카드
    let cardView: WorkerNativeEmployCard = {
        let view = WorkerNativeEmployCard()
        view.setToPostAppearance()
        return view
    }()
    
    /// 지도뷰
    let workPlaceAndWorkerLocationView = WorkPlaceAndWorkerLocationView()
    
    /// 공고 상세정보들
    let workConditionView = WorkConditionDisplayingView()
    let customerInfoView = CustomerInformationDisplayingView(userType: .worker)
    let applicationDetailView = ApplicationDetailDisplayingView()
    
    /// 센터 프로필로 이동하는 카드및 센터정보 표시
    let centerInfoCard = CenterInfoCardView()
    
    public init() {
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    func setAppearance() {
        
        self.layoutMargins = .init(top: 24, left: 0, bottom: 16, right: 0)
    }
    
    func setLayout() {
        
        let titleViewData: [(title: String, view: UIView)] = [
            ("근무 장소", workPlaceAndWorkerLocationView),
            ("근무 조건", workConditionView),
            ("고객 정보", customerInfoView),
            ("추가 지원 정보", applicationDetailView),
            ("기관 정보", centerInfoCard),
        ]
        
        // 카드뷰 따로추가
        let cardPartView = UIView()
        cardPartView.backgroundColor = .white
        cardPartView.layoutMargins = .init(top: 0, left: 20, bottom: 24, right: 20)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardPartView.addSubview(cardView)
         
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.topAnchor),
            cardView.leftAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.leftAnchor),
            cardView.rightAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.rightAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardPartView.layoutMarginsGuide.bottomAnchor),
        ])
        
        var viewList = [cardPartView]
        
        let titleViewList = titleViewData.map { (title, view) in
            
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
        
        viewList.append(contentsOf: titleViewList)
        
        let contentViewStack = VStack(viewList, spacing: 8, alignment: .fill)
        contentViewStack.backgroundColor = DSKitAsset.Colors.gray050.color
        
        [
            contentViewStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            contentViewStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            contentViewStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            contentViewStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            contentViewStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        
    }
}
