//
//  CenterSettingVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/19/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

class CenterSettingViewController: BaseViewController {
    
    // Init
    
    // View
    let titleBar: IdleTitleBar = {
        let bar = IdleTitleBar(titleText: "설정", innerViews: [])
        return bar
    }()
    
    let myCenterInfoButton: FullRowButton = {
        let button = FullRowButton(labelText: "내 센터 정보")
        return button
    }()
    let centerInfoCard: CenterInfoCardView = {
        let view = CenterInfoCardView()
        view.chevronLeftImage.isHidden = true
        return view
    }()
    let pushNotificationAuthRow: PushNotificationAuthRow = {
        let row = PushNotificationAuthRow()
        return row
    }()
    let frequentQuestionButton: FullRowButton = {
        let button = FullRowButton(labelText: "자주 묻는 질문")
        return button
    }()
    let askButton: FullRowButton = {
        let button = FullRowButton(labelText: "문의하기")
        return button
    }()
    let applicationPolicyButton: FullRowButton = {
        let button = FullRowButton(labelText: "약관및 정책")
        return button
    }()
    let personalDataProcessingPolicyButton: FullRowButton = {
        let button = FullRowButton(labelText: "개인정보 처리방침")
        return button
    }()
    let signOutButton: IdleUnderLineLabelButton = {
        let button = IdleUnderLineLabelButton(labelText: "로그아웃")
        button.backgroundColor = .clear
        return button
    }()
    let removeAccountButton: IdleUnderLineLabelButton = {
        let button = IdleUnderLineLabelButton(labelText: "회원 탈퇴")
        button.backgroundColor = .clear
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func bind(viewModel: CenterSettingVMable) {
        
        super.bind(viewModel: viewModel)
        
        // Input
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        Observable.merge(
            myCenterInfoButton.rx.tap.asObservable(),
            centerInfoCard.rx.tap.asObservable()
        )
            .bind(to: viewModel.myCenterProfileButtonClicked)
            .disposed(by: disposeBag)
        
        pushNotificationAuthRow.`switch`.rx.isOn
            .map({ [pushNotificationAuthRow] isOn in
                
                // On / Off 여부는 ViewModel이 설정한다.
                pushNotificationAuthRow.`switch`.setOn(false, animated: false)
                
                return isOn
            })
            .bind(to: viewModel.approveToPushNotification)
            .disposed(by: disposeBag)
        
        removeAccountButton.rx.tap
            .bind(to: viewModel.removeAccountButtonClicked)
            .disposed(by: disposeBag)
        
        // 설정화면에 종속적인 뷰들입니다.
        Observable
            .merge(
                frequentQuestionButton.rx.tap
                    .map { _ in SettingAdditionalInfoType.frequentQuestion },
                askButton.rx.tap
                    .map { _ in SettingAdditionalInfoType.contact },
                applicationPolicyButton.rx.tap
                    .map { _ in SettingAdditionalInfoType.termsandPolicies },
                personalDataProcessingPolicyButton.rx.tap
                    .map { _ in SettingAdditionalInfoType.privacyPolicy }
            )
            .bind(to: viewModel.additionalInfoButtonClieck)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .pushNotificationApproveState?
            .drive(onNext: { [weak self] isOn in
                self?.pushNotificationAuthRow.`switch`.setOn(isOn, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .centerInfo?
            .drive(onNext: { [weak self] info in
                self?.centerInfoCard.bind(nameText: info.name, locationText: info.location)
            })
            .disposed(by: disposeBag)
        
        // MARK: 세팅화면으로 이동
        viewModel
            .showSettingAlert?
            .drive(onNext: {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = DSColor.gray050.color
        
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        let myCenterInfoContainer = VStack([
            myCenterInfoButton,
            HStack([
                Spacer(width: 20),
                centerInfoCard,
                Spacer(width: 20),
            ]),
            Spacer(height: 12),
        ], alignment: .fill)
        
        myCenterInfoContainer.backgroundColor = DSColor.gray0.color
        
        let viewList = [
            myCenterInfoContainer,
            Spacer(height: 8),
            pushNotificationAuthRow,
            Spacer(height: 8),
            frequentQuestionButton,
            askButton,
            Spacer(height: 8),
            applicationPolicyButton,
            Spacer(height: 8),
            personalDataProcessingPolicyButton,
            Spacer(height: 20),
            HStack([Spacer(width: 20), signOutButton, Spacer()]),
            Spacer(height: 24),
            HStack([Spacer(width: 20), removeAccountButton, Spacer()]),
        ]
        
        let contentView = VStack(viewList, alignment: .fill)
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
        ])
        
        
        // main view
        [
            titleBar,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
        signOutButton
            .rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self, let vm = viewModel as? CenterSettingVMable else { return }
                let signOutVM = vm.createSingOutVM()
                showIdleModal(viewModel: signOutVM)
            })
            .disposed(by: disposeBag)
    }
}


@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    CenterSettingViewController()
}
