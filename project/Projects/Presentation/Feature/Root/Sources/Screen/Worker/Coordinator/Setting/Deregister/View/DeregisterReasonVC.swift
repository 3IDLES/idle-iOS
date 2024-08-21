//
//  DeregisterReasonVC.swift
//  RootFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import BaseFeature
import RxCocoa
import RxSwift
import Entity
import DSKit
import Entity

public protocol DeregisterReasonVMable {
    var coordinator: DeregisterCoordinator? { get }
    var acceptDeregisterButonClicked: PublishRelay<[DeregisterReasonVO]> { get }
}

public class DeregisterReasonVC: BaseViewController {
    
    // Init
    
    // Not init
    var viewModel: DeregisterReasonVMable?
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(innerViews: [])
        bar.titleLabel.textString = "계정 삭제"
        return bar
    }()
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "정말 탈퇴하시겠어요?"
        return label
    }()
    let subTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textString = "계정을 삭제하시려는 이유를 알려주세요.\n소중한 피드백을 받아 더 나은 서비스로 보답하겠습니다."
        label.attrTextColor = DSColor.gray300.color
        return label
    }()
    var itemViewList: [CheckBoxWithLabelView] = {
        DeregisterReasonVO.allCases.map { vo in
            return CheckBoxWithLabelView(
                item: vo,
                labelText: vo.reasonText
            )
        }
    }()
    
    let finalWarningLabel: IdleLabel = {
        let label = IdleLabel(typography: .caption)
        label.textString = "탈퇴 버튼 선택 시 모든 정보가 삭제되며, 되돌릴 수 없습니다."
        label.attrTextColor = DSColor.red100.color
        return label
    }()
    
    let cancelButton: IdleThirdinaryButton = {
        let button = IdleThirdinaryButton(level: .medium)
        button.label.textString = "취소하기"
        return button
    }()
    
    let acceptDeregisterButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .mediumRed)
        button.label.textString = "탈퇴하기"
        button.setEnabled(false)
        return button
    }()
    
    // Observable
    private var selectedReasons: [DeregisterReasonVO: Bool] = {
        var dict: [DeregisterReasonVO: Bool] = [:]
        DeregisterReasonVO.allCases.forEach { vo in
            dict[vo] = false
        }
        return dict
    }()
    
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        let checkListScrollView = UIScrollView()
        checkListScrollView.contentInset.top = 32
        let contentGuide = checkListScrollView.contentLayoutGuide
        let frameGuide = checkListScrollView.frameLayoutGuide
        let contentStack = VStack(itemViewList, spacing: 16, alignment: .fill)
        checkListScrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor, constant: -20),
            
            contentStack.leftAnchor.constraint(equalTo: frameGuide.leftAnchor, constant: 20),
            contentStack.rightAnchor.constraint(equalTo: frameGuide.rightAnchor, constant: 20),
        ])
        
        let titleLabelStack = VStack([
            titleLabel,
            subTitleLabel
        ], spacing: 8, alignment: .leading)
        
        let buttonStack = HStack(
            [
                cancelButton,
                acceptDeregisterButton
            ],
            spacing: 8,
            alignment: .center,
            distribution: .fillEqually
        )
            
        [
            navigationBar,
            titleLabelStack,
            checkListScrollView,
            finalWarningLabel,
            buttonStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            titleLabelStack.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 24),
            titleLabelStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            titleLabelStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            
            checkListScrollView.topAnchor.constraint(equalTo: titleLabelStack.bottomAnchor),
            checkListScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            checkListScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            checkListScrollView.bottomAnchor.constraint(equalTo: finalWarningLabel.bottomAnchor),
            
            finalWarningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finalWarningLabel.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -12),
            
            buttonStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            buttonStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
    }
    
    private func setObservable() {
        
        itemViewList.forEach { itemView in
            
            itemView
                .opTap
                .observe(on: MainScheduler.instance)
                .map({ [weak self] state in
                    
                    switch state {
                    case .idle(let item):
                        self?.selectedReasons[item] = false
                    case .checked(let item):
                        self?.selectedReasons[item] = true
                    }
                    return state
                })
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    let selectCount = selectedReasons.values.filter { $0 }.count
                    acceptDeregisterButton.setEnabled(selectCount > 0)
                })
                .disposed(by: disposeBag)
        }
    }
    
    public func bind(viewModel: DeregisterReasonVMable) {
        
        acceptDeregisterButton
            .rx.tap
            .map { [weak self] _ in
                let reasons = self?.selectedReasons.filter({ (reason, isActive) in isActive}).map { (key, _) in
                    key
                }
                return reasons ?? []
            }
            .bind(to: viewModel.acceptDeregisterButonClicked)
            .disposed(by: disposeBag)
        
    }
}

