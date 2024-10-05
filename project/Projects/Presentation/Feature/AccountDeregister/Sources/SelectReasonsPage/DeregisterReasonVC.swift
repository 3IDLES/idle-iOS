//
//  DeregisterReasonVC.swift
//  AccountDeregisterFeature
//
//  Created by choijunios on 8/21/24.
//

import UIKit
import PresentationCore
import BaseFeature
import Domain
import DSKit


import RxCocoa
import RxSwift

public protocol DeregisterReasonVMable: BaseViewModel {
    var userType: UserType { get }
    var exitButonClicked: PublishRelay<Void> { get }
    var acceptDeregisterButonClicked: PublishRelay<[String]> { get }
}

public class DeregisterReasonVC: BaseViewController {
    
    // Init
    
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
    
    private let mainScrollView = UIScrollView()
    
    let itemViewList: [CheckBoxWithLabelView] = {
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
        label.textAlignment = .center
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
    
    fileprivate let deregisterReasonField1: DeregisterInputField = {
        let field = DeregisterInputField(
            titleText: "어떤 부분에서 불편함을 느끼셨나요?",
            fieldText: "어떤 부분에서 불편함을 느끼셨나요? 보내주신 의견은 플랫폼 개선에 큰 도움이 됩니다!"
        )
        field.isHidden = true
        return field
    }()
    
    fileprivate let deregisterReasonField2: DeregisterInputField = {
        let field = DeregisterInputField(
            titleText: "어떤 기능이 필요하신가요?",
            fieldText: "어떤 기능이 필요하신가요? 보내주신 의견은 개발 담당자에게 즉시 전달됩니다."
        )
        field.isHidden = true
        return field
    }()
    
    // Observable
    private var selectedReasons: [DeregisterReasonVO: Bool] = {
        var dict: [DeregisterReasonVO: Bool] = [:]
        DeregisterReasonVO.allCases.forEach { vo in
            dict[vo] = false
        }
        return dict
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
        setKeyboardAvoidance()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        mainScrollView.contentInset.top = 36
        mainScrollView.contentInset.bottom = 12

        let contentView: UIView = .init()
        let contentGuide = mainScrollView.contentLayoutGuide
        let frameGuide = mainScrollView.frameLayoutGuide
        
        // MARK: 체크리스트 + 텍스트필드
        let checkListStack = VStack(itemViewList, spacing: 16, alignment: .fill)
        
        // inputField 삽입
        checkListStack.insertArrangedSubview(deregisterReasonField1, at: 2)
        checkListStack.insertArrangedSubview(deregisterReasonField2, at: 6)
        
        let titleLabelStack = VStack([
            titleLabel,
            subTitleLabel
        ], spacing: 8, alignment: .leading)
        
        [
            titleLabelStack,
            checkListStack,
            finalWarningLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        mainScrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            titleLabelStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabelStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabelStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            checkListStack.topAnchor.constraint(equalTo: titleLabelStack.bottomAnchor, constant: 32),
            checkListStack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            checkListStack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            checkListStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            // contentView - ScrollView
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            
            contentView.leftAnchor.constraint(equalTo: frameGuide.leftAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: frameGuide.rightAnchor, constant: -20),
        ])
            
        // MARK: 하단 버튼
        let buttonStack = HStack(
            [
                cancelButton,
                acceptDeregisterButton
            ],
            spacing: 8,
            alignment: .center,
            distribution: .fillEqually
        )
        
        let bottomStack = VStack([
            finalWarningLabel,
            buttonStack
        ], spacing: 12, alignment: .fill)
        
        // MARK: main
        [
            navigationBar,
            mainScrollView,
            bottomStack,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            mainScrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            mainScrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mainScrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor),
            
            bottomStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            bottomStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
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
        
        super.bind(viewModel: viewModel)
        
        if viewModel.userType == .worker {
            
            itemViewList[1]
                .opTap
                .subscribe { [weak self] _ in
                    self?.deregisterReasonField1.isHidden.toggle()
                }
                .disposed(by: disposeBag)
            
            itemViewList[4]
                .opTap
                .subscribe { [weak self] _ in
                    self?.deregisterReasonField2.isHidden.toggle()
                }
                .disposed(by: disposeBag)
        }
        
        acceptDeregisterButton
            .rx.tap
            .map { [weak self] _ in
                
                // 선택항목
                var reasons = self?.selectedReasons.filter({ (reason, isActive) in isActive}).map { (key, _) in
                    key.reasonText
                }
                
                // 불편했던 점
                if let str = self?.deregisterReasonField1.reasonField.attributedText.string, !str.isEmpty {
                    let formedStr = "불편했던 점: \(str)"
                    reasons?.append(formedStr)
                }
                
                // 필요한 기능
                if let str = self?.deregisterReasonField2.reasonField.attributedText.string, !str.isEmpty {
                    let formedStr = "필요한 기능: \(str)"
                    reasons?.append(formedStr)
                }
                
                // 어떤 기능
                
                return reasons ?? []
            }
            .bind(to: viewModel.acceptDeregisterButonClicked)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                cancelButton.rx.tap.asObservable(),
                navigationBar.backButton.rx.tap.asObservable()
            )
            .bind(to: viewModel.exitButonClicked)
            .disposed(by: disposeBag)
    }
    
    func setKeyboardAvoidance() {
        
        [
            deregisterReasonField1.reasonField,
            deregisterReasonField2.reasonField
        ].forEach { (view: IdleKeyboardAvoidable) in
            
            view.setKeyboardAvoidance(movingView: mainScrollView)
        }
    }
}


fileprivate class DeregisterInputField: VStack {
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textAlignment = .left
        label.attrTextColor = DSColor.gray500.color
        return label
    }()
    
    let reasonField: MultiLineTextField = {
        let field = MultiLineTextField(typography: .Body3)
        field.isScrollEnabled = false
        return field
    }()
    
    init(titleText: String, fieldText: String) {
        self.titleLabel.textString = titleText
        self.reasonField.placeholderText = fieldText
        super.init([titleLabel, reasonField], spacing: 6, alignment: .fill)
        
        NSLayoutConstraint.activate([
            reasonField.heightAnchor.constraint(equalToConstant: 156)
        ])
    }
    
    required init(coder: NSCoder) { fatalError() }
}
