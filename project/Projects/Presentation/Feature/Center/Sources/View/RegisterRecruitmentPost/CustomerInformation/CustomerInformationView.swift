//
//  CustomerInformationView.swift
//  CenterFeature
//
//  Created by choijunios on 7/31/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
 

public protocol CustomerInformationViewModelable {
    var name: PublishRelay<String> { get }
    var gender: PublishRelay<Gender> { get }
    var birthYear: PublishRelay<String> { get }
    var weight: PublishRelay<String> { get }
    var careGrade: PublishRelay<CareGrade> { get }
    var cognitionState: PublishRelay<CognitionDegree> { get }
    var deceaseDescription: PublishRelay<String> { get }
    
    var customerInformationStateObject: Driver<CustomerInformationStateObject> { get }
    var customerInformationNextable: Driver<Bool> { get }
}

public class CustomerInformationView: UIView, RegisterRecruitmentPostViews {
    
    // Init
        
    // Not init
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "고객 정보를 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    // 이름 입력
    lazy var nameField: IdleOneLineInputField = {
        let field = IdleOneLineInputField(placeHolderText: "고객의 이름을 입력해 주세요.")
        field.setKeyboardAvoidance(movingView: self)
        return field
    }()
    
    // 성별 선택
    let maleBtn: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "남성", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    let femaleBtn: StateButtonTyp1 = {
        let btn = StateButtonTyp1(text: "여성", initial: .normal)
        btn.label.typography = .Body3
        return btn
    }()
    
    // 출생연도
    lazy var birthYearField: IdleOneLineInputField = {
        let field = IdleOneLineInputField(placeHolderText: "고객의 출생연도를 입력해주세요. (예: 1965)")
        field.setKeyboardAvoidance(movingView: self)
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    // 몸무게
    lazy var weightField: TextFieldWithDegree = {
        let field = TextFieldWithDegree(
            degreeText: "kg",
            initialText: ""
        )
        field.setKeyboardAvoidance(movingView: self)
        field.textField.keyboardType = .numberPad
        return field
    }()
    
    // 요양등급
    let careGradeButtons: [StateButtonTyp1] = {
        CareGrade.allCases.map { grade in
            StateButtonTyp1(
                text: grade.textForCellBtn,
                initial: .normal
            )
        }
    }()
    
    // 인지상태
    let cognitionButtons: [StateButtonTyp1] = {
        CognitionDegree.allCases.map { cognition in
            StateButtonTyp1(
                text: cognition.korTextForCellBtn,
                initial: .normal
            )
        }
    }()
    
    // 질병
    lazy var deceaseField: IdleOneLineInputField = {
        let field = IdleOneLineInputField(placeHolderText: "고객이 현재 앓고 있는 질병 또는 병력을 입력해주세요.")
        field.setKeyboardAvoidance(movingView: self)
        return field
    }()
    
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    // Radio Btn을 위한 처리
    private let selectedGender: PublishRelay<Gender> = .init()
    private let selectedCareGrade: PublishRelay<CareGrade> = .init()
    private let selectedCognitionState: PublishRelay<CognitionDegree> = .init()
    
    private let disposeBag = DisposeBag()
    
    public init() {
        
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
        setObservable()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .clear
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        // 정적 크기
        [
            [maleBtn, femaleBtn],
            cognitionButtons
        ]
        .flatMap { $0 }
        .forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 104),
                view.heightAnchor.constraint(equalToConstant: 44),
            ])
        }
        
        careGradeButtons
            .forEach { view in
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: 40),
                    view.heightAnchor.constraint(equalToConstant: 40),
                ])
            }
        
        let stackList: [VStack] = [
        
            VStack(
                [
                    IdleContentTitleLabel(titleText: "이름"),
                    nameField
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "성별"),
                    HStack([maleBtn, femaleBtn, UIView()], spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "출생연도"),
                    birthYearField
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "몸무게"),
                    weightField
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "출생연도"),
                    HStack([
                        careGradeButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "인지상태"),
                    HStack([
                        cognitionButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "질병", subTitleText: "(선택)"),
                    weightField
                ],
                spacing: 6,
                alignment: .fill
            ),
        ]
        
        let scrollView = UIScrollView()
        scrollView.contentInset = .init(
            top: 0,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        let scrollViewContentStack = VStack(
            stackList,
            spacing: 28,
            alignment: .fill
        )
        
        scrollView.delaysContentTouches = false
        scrollView.addSubview(scrollViewContentStack)
        scrollViewContentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollViewContentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollViewContentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollViewContentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollViewContentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])
        
        [
            processTitle,
            
            scrollView,
            
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }

    
    private func setObservable() { }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        // Input
        nameField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                maleBtn.eventPublisher
                    .compactMap { state -> Gender? in state == .accent ? .male : nil },
                femaleBtn.eventPublisher
                    .compactMap { state -> Gender? in state == .accent ? .female : nil }
            ).map { [maleBtn, femaleBtn] (selectedGender) in
                
                if selectedGender == .male {
                    femaleBtn.setState(.normal)
                } else {
                    maleBtn.setState(.normal)
                }
                
                return selectedGender
            }
            .bind(to: viewModel.gender)
            .disposed(by: disposeBag)
        
        birthYearField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.birthYear)
            .disposed(by: disposeBag)
        
        weightField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.weight)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                careGradeButtons
                    .enumerated()
                    .map { (index, button) in
                        let item = CareGrade(rawValue: index)!
                        return button.eventPublisher
                            .compactMap { state -> CareGrade? in state == .accent ? item : nil }
                            .asObservable()
                    }
            )
            .map { [careGradeButtons] (grade) in
                
                careGradeButtons
                    .enumerated()
                    .forEach { (index, button) in
                        let item = CareGrade(rawValue: index)!
                        if item != grade {
                            button.setState(.normal)
                        }
                    }
                
                return grade
            }
            .bind(to: viewModel.careGrade)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                cognitionButtons
                    .enumerated()
                    .map { (index, button) in
                        let item = CognitionDegree(rawValue: index)!
                        return button.eventPublisher
                            .compactMap { state -> CognitionDegree? in state == .accent ? item : nil }
                            .asObservable()
                    }
            )
            .map { [cognitionButtons] (grade) in
                
                cognitionButtons
                    .enumerated()
                    .forEach { (index, button) in
                        let item = CognitionDegree(rawValue: index)!
                        if item != grade {
                            button.setState(.normal)
                        }
                    }
                
                return grade
            }
            .bind(to: viewModel.cognitionState)
            .disposed(by: disposeBag)
        
        
        deceaseField.textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.deceaseDescription)
            .disposed(by: disposeBag)
        
        // output
        viewModel
            .customerInformationStateObject
            .drive(onNext: { [weak self] stateFromVM in
              
                guard let self else { return }
                
                // 이름
                if !stateFromVM.name.isEmpty {
                    nameField.textField.textString = stateFromVM.name
                }
                
                // 성별
                if let gender = stateFromVM.gender {
                    if gender == .male {
                        maleBtn.setState(.accent)
                    } else {
                        femaleBtn.setState(.accent)
                    }
                }
                
                // 출생년도
                if !stateFromVM.birthYear.isEmpty {
                    birthYearField.textField.textString = stateFromVM.birthYear
                }
                
                // 몸무게
                if !stateFromVM.weight.isEmpty {
                    weightField.textField.textString = stateFromVM.weight
                }
                
                // 요양등급
                if let state = stateFromVM.careGrade {
                    
                    careGradeButtons
                        .enumerated()
                        .forEach { (index, button) in
                            let item = CareGrade(rawValue: index)!
                            
                            if item == state {
                                button.setState(.accent)
                            }
                        }
                }
                
                // 인지상태
                if let state = stateFromVM.cognitionState {
                    
                    cognitionButtons
                        .enumerated()
                        .forEach { (index, button) in
                            let item = CognitionDegree(rawValue: index)!
                            
                            if item == state {
                                button.setState(.accent)
                            }
                        }
                }
                
                // 질병
                if !stateFromVM.deceaseDescription.isEmpty {
                    deceaseField.textField.textString = stateFromVM.deceaseDescription
                }
            })
            .disposed(by: disposeBag)
        
        
        viewModel
            .customerInformationNextable
            .drive(onNext: { [ctaButton] nextable in
                ctaButton.setEnabled(nextable)
            })
            .disposed(by: disposeBag)
    }
}
