//
//  EditPostVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/5/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public protocol EditPostViewModelable:
    BaseViewModel,
    ApplicationDetailContentVMable,
    CustomerInformationContentVMable,
    CustomerRequirementContentVMable,
    WorkTimeAndPayContentVMable,
    AddressInputViewContentVMable
{
    var editPostCoordinator: EditPostCoordinator? { get set }
    var editViewExitButtonClicked: PublishRelay<Void> { get }
    var saveButtonClicked: PublishRelay<Void> { get }
    var requestSaveFailure: Driver<DefaultAlertContentVO>? { get }
}

public class EditPostVC: BaseViewController {
    
    // Init
    
    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "공고 수정")
        return bar
    }()
    
    let editingCompleteButton: TextButtonType3 = {
        let btn = TextButtonType3(typography: .Subtitle2)
        btn.textString = "저장"
        btn.attrTextColor = DSKitAsset.Colors.orange500.color
        return btn
    }()
    
    let workTimeAndPaymentEditView: WorkTimeAndPayContentView
    private(set) var addressInputEditView: AddressContentView!
    let customerInfoEditView: CustomerInformationContentView
    let customerRequirementEditView: CustomerRequirementContentView
    private(set) var applyInfoEditView: ApplicationDetailViewContentView!
    
    public init() {
        self.workTimeAndPaymentEditView = WorkTimeAndPayContentView()
        self.customerInfoEditView = CustomerInformationContentView()
        self.customerRequirementEditView = CustomerRequirementContentView()
        
        super.init(nibName: nil, bundle: nil)
        applyInfoEditView = ApplicationDetailViewContentView(viewController: self)
        addressInputEditView = AddressContentView(viewController: self)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
        setObservable()
        setKeyboardAvoidance()
    }
    
    private func setAppearance() {
        view.backgroundColor = .white
    }
    
    private func setLayout() {
        // 상단 네비게이션바 세팅
        let navigationBarStack = HStack(
            [navigationBar, editingCompleteButton],
            distribution: .equalSpacing
        )
        navigationBarStack.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 12,
            right: 0
        )
        
        let label1 = IdleLabel(typography: .Subtitle1)
        label1.textAlignment = .left
        label1.textString = "근무 조건"
        
        let view1 = UIView()
        view1.backgroundColor = .white
        view1.layoutMargins = .init(
            top: 20,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        [
            label1,
            workTimeAndPaymentEditView,
            addressInputEditView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view1.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: view1.layoutMarginsGuide.topAnchor),
            label1.leftAnchor.constraint(equalTo: view1.layoutMarginsGuide.leftAnchor),
            
            workTimeAndPaymentEditView.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 20),
            workTimeAndPaymentEditView.leftAnchor.constraint(equalTo: view1.layoutMarginsGuide.leftAnchor),
            workTimeAndPaymentEditView.rightAnchor.constraint(equalTo: view1.layoutMarginsGuide.rightAnchor),
            
            addressInputEditView.topAnchor.constraint(equalTo: workTimeAndPaymentEditView.bottomAnchor, constant: 20),
            addressInputEditView.leftAnchor.constraint(equalTo: view1.layoutMarginsGuide.leftAnchor),
            addressInputEditView.rightAnchor.constraint(equalTo: view1.layoutMarginsGuide.rightAnchor),
            addressInputEditView.bottomAnchor.constraint(equalTo: view1.layoutMarginsGuide.bottomAnchor),
        ])
        
        let label2 = IdleLabel(typography: .Subtitle1)
        label2.textAlignment = .left
        label2.textString = "고객 정보"
        
        let view2 = UIView()
        view2.backgroundColor = .white
        view2.layoutMargins = .init(
            top: 20,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        let divider = Spacer(height: 1)
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        [
            label2,
            customerInfoEditView,
            divider,
            customerRequirementEditView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view2.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            label2.topAnchor.constraint(equalTo: view2.layoutMarginsGuide.topAnchor),
            label2.leftAnchor.constraint(equalTo: view2.layoutMarginsGuide.leftAnchor),
            
            customerInfoEditView.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 20),
            customerInfoEditView.leftAnchor.constraint(equalTo: view2.layoutMarginsGuide.leftAnchor),
            customerInfoEditView.rightAnchor.constraint(equalTo: view2.layoutMarginsGuide.rightAnchor),
            
            divider.topAnchor.constraint(equalTo: customerInfoEditView.bottomAnchor, constant: 20),
            divider.leftAnchor.constraint(equalTo: view2.layoutMarginsGuide.leftAnchor),
            divider.rightAnchor.constraint(equalTo: view2.layoutMarginsGuide.rightAnchor),
            
            customerRequirementEditView.topAnchor.constraint(equalTo: divider.topAnchor, constant: 20),
            customerRequirementEditView.leftAnchor.constraint(equalTo: view2.layoutMarginsGuide.leftAnchor),
            customerRequirementEditView.rightAnchor.constraint(equalTo: view2.layoutMarginsGuide.rightAnchor),
            customerRequirementEditView.bottomAnchor.constraint(equalTo: view2.layoutMarginsGuide.bottomAnchor),
        ])
        
        let view3 = UIView()
        view3.backgroundColor = .white
        view3.layoutMargins = .init(
            top: 20,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        let label3 = IdleLabel(typography: .Subtitle1)
        label3.textAlignment = .left
        label3.textString = "추가 지원 정보"
        
        [
            label3,
            applyInfoEditView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view3.addSubview($0)
        }
    
        NSLayoutConstraint.activate([
            label3.topAnchor.constraint(equalTo: view3.layoutMarginsGuide.topAnchor),
            label3.leftAnchor.constraint(equalTo: view3.layoutMarginsGuide.leftAnchor),
            
            applyInfoEditView.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 20),
            applyInfoEditView.leftAnchor.constraint(equalTo: view3.layoutMarginsGuide.leftAnchor),
            applyInfoEditView.rightAnchor.constraint(equalTo: view3.layoutMarginsGuide.rightAnchor),
            applyInfoEditView.bottomAnchor.constraint(equalTo: view3.layoutMarginsGuide.bottomAnchor),
        ])
            
            
        let contentView = VStack(
            [view1, view2, view3],
            spacing: 8,
            alignment: .fill
        )
        contentView.backgroundColor = DSKitAsset.Colors.gray050.color
        
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        let navigationBarDivider = Spacer(height: 1)
        navigationBarDivider.backgroundColor = DSKitAsset.Colors.gray100.color
        
        [
            navigationBarStack,
            navigationBarDivider,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBarStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            navigationBarStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationBarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            navigationBarDivider.topAnchor.constraint(equalTo: navigationBarStack.bottomAnchor, constant: 24),
            navigationBarDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBarDivider.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setKeyboardAvoidance() {
        
        [
            workTimeAndPaymentEditView.paymentField,
            addressInputEditView.detailAddressField,
            customerInfoEditView.nameField,
            customerInfoEditView.birthYearField,
            customerInfoEditView.weightField,
            customerInfoEditView.deceaseField,
            customerRequirementEditView.additionalRequirmentField
        ].forEach { (view: IdleKeyboardAvoidable) in
            
            view.setKeyboardAvoidance(movingView: self.view)
        }
    }
    
    private func setObservable() {
        
        
    }
    
    public func bind(viewModel: EditPostViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        editingCompleteButton
            .eventPublisher
            .bind(to: viewModel.saveButtonClicked)
            .disposed(by: disposeBag)
        
        navigationBar
            .eventPublisher
            .bind(to: viewModel.editViewExitButtonClicked)
            .disposed(by: disposeBag)
        
        viewModel
            .requestSaveFailure?
            .drive(onNext: { [weak self] alertVO in
                
                self?.showAlert(vo: alertVO)
            })
            .disposed(by: disposeBag)
        
        workTimeAndPaymentEditView.bind(viewModel: viewModel)
        addressInputEditView.bind(viewModel: viewModel)
        customerInfoEditView.bind(viewModel: viewModel)
        customerRequirementEditView.bind(viewModel: viewModel)
        applyInfoEditView.bind(viewModel: viewModel)
    }
}

