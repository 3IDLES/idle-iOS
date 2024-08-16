//
//  PostDetailForWorkerVC.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public struct WorkAndWorkerLocationMapRO {
    
    let workLocation: LocationInformation
    let workerLocation: LocationInformation
}

/// 센토도 요양보호사가 보는 공고화면을 볼 수 있기 때문에 해당뷰를 BaseFeature에 구현하였습니다.
public class PostDetailForWorkerVC: BaseViewController {
    
    var viewModel: PostDetailForWorkerViewModelable?
    
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
        return btn
    }()
    
    
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
    
    private func setObservable() {
        
        // '문의하기'버튼 클릭시
        csButton.rx.tap
            .subscribe { [weak self] _ in
                let vc = SelectCSTypeVC()
                vc.modalPresentationStyle = .overFullScreen
                self?.present(vc, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: PostDetailForWorkerViewModelable) {
        
        self.viewModel = viewModel
        
        // Output
        viewModel
            .postForWorkerBundle?
            .drive(onNext: {
                [weak self] bundle in
                guard let self else { return }
                
                // 상단 구인공고 카드
                contentView.cardView.bind(
                    ro: WorkerEmployCardRO.create(
                        vo: .create(
                            workTimeAndPay: bundle.workTimeAndPay,
                            customerRequirement: bundle.customerRequirement,
                            customerInformation: bundle.customerInformation,
                            applicationDetail: bundle.applicationDetail,
                            addressInfo: bundle.addressInfo
                        )
                    )
                )
                
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
        
        
        viewModel
            .locationInfo?
            .drive(onNext: { bundle in
                
                // 위치정보 전달
                
            })
            .disposed(by: disposeBag)
        
        viewModel
            .alert?
            .drive(onNext: { [weak self] alertVO in
                self?.showAlert(vo: alertVO)
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
            .eventPublisher
            .map { state in return state == .accent }
            .bind(to: viewModel.startButtonClicked)
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
    let cardView: WorkerEmployCard = {
        let view = WorkerEmployCard()
        view.setToPostAppearance()
        return view
    }()
    
    /// 지도뷰
    let workLocationView = WorkLocationView()
    
    /// 공고 상세정보들
    let workConditionView = WorkConditionDisplayingView()
    let customerInfoView = CustomerInformationDisplayingView()
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
            ("근무 장소", workLocationView),
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
