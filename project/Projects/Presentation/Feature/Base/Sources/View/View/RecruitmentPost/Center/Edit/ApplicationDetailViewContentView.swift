//
//  ApplicationDetailViewContentView.swift
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

public protocol ApplicationDetailContentVMable {
    
    // Input
    var experiencePreferenceType: PublishRelay<ExperiencePreferenceType> { get }
    var applyType: PublishRelay<(ApplyType, Bool)> { get }
    var applyDeadlineType: PublishRelay<ApplyDeadlineType> { get }
    var deadlineDate: BehaviorRelay<Date?> { get }
    
    // Output
    var deadlineString: Driver<String> { get }
    var applicationDetailViewNextable: Driver<Bool> { get }
    var casting_applicationDetail: Driver<ApplicationDetailStateObject> { get }
}

public class ApplicationDetailViewContentView: UIView {
    
    // Init
    public weak var viewController: UIViewController?
    
    // 경력우대 여부
    let expButtons: [StateButtonTyp1] = {
        ExperiencePreferenceType.allCases.map { type in
            StateButtonTyp1(
                text: type.korTextForBtn,
                initial: .normal
            )
        }
    }()
    
    // 지원 방법
    let applyTypeButtons: [StateButtonTyp1] = {
        ApplyType.allCases.map { type in
            StateButtonTyp1(
                text: type.korTextForBtn,
                initial: .normal
            )
        }
    }()
    
    // 접수 마감 타입
    let deadlineTypeButtons: [StateButtonTyp1] = {
        ApplyDeadlineType.allCases.map { type in
            StateButtonTyp1(
                text: type.korTextForBtn,
                initial: .normal
            )
        }
    }()
    
    // 날짜 선택 버튼
    let calendarOpenButton: CalendarOpenButton = {
        let view = CalendarOpenButton()
        view.isHidden = true
        return view
    }()
    
    
    private let deadlineDate: PublishRelay<Date> = .init()
    
    private let disposeBag = DisposeBag()
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(frame: .zero)
        setLayout()
        setObservable()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    
    func setLayout() {
        
        // 정적 크기
        [
            expButtons,
            applyTypeButtons,
            deadlineTypeButtons
        ]
        .flatMap { $0 }
        .forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 104),
                view.heightAnchor.constraint(equalToConstant: 44),
            ])
        }
        
        let stackList: [VStack] = [
        
            VStack(
                [
                    IdleContentTitleLabel(titleText: "경력 우대 여부"),
                    HStack([
                        expButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "지원 방법", subTitleText: "(다중 선택 가능)"),
                    HStack([
                        applyTypeButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
            
            VStack(
                [
                    IdleContentTitleLabel(titleText: "접수 마감일"),
                    HStack([
                        deadlineTypeButtons as [UIView],
                        [UIView()]
                    ].flatMap({ $0 }), spacing: 4),
                ],
                spacing: 6,
                alignment: .fill
            ),
        ]
        
        let scrollViewContentStack = VStack(
            stackList,
            spacing: 28,
            alignment: .fill
        )
        
        [
            scrollViewContentStack,
            calendarOpenButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollViewContentStack.topAnchor.constraint(equalTo: self.topAnchor),
            scrollViewContentStack.leftAnchor.constraint(equalTo: self.leftAnchor),
            scrollViewContentStack.rightAnchor.constraint(equalTo: self.rightAnchor),
            
            calendarOpenButton.topAnchor.constraint(equalTo: scrollViewContentStack.bottomAnchor, constant: 12),
            calendarOpenButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            calendarOpenButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            calendarOpenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setObservable() {
        
        deadlineTypeButtons[1]
            .eventPublisher
            .map({ !($0 == .accent) })
            .bind(to: calendarOpenButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        calendarOpenButton
            .rx.tap
            .subscribe { [weak self, weak viewController] _ in
                
                let vc = OneDayPickerViewController()
                vc.delegate = self
                vc.modalPresentationStyle = .overFullScreen
                viewController?.present(vc, animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: ApplicationDetailContentVMable) {
        
        // Output
        
        viewModel
            .casting_applicationDetail
            .drive(onNext: { [weak self] stateFromVM in
                
                guard let self else { return }
                
                // 경력 우대 여부
                if let state = stateFromVM.experiencePreferenceType {
                    
                    expButtons
                        .enumerated()
                        .forEach { (index, button) in
                            let item = ExperiencePreferenceType(rawValue: index)!
                            
                            if item == state {
                                button.setState(.accent)
                            }
                        }
                }
                
                applyTypeButtons
                    .enumerated()
                    .forEach { (index, button) in
                        let currentButtonItem = ApplyType(rawValue: index)!
                        let isActive = stateFromVM.applyType[currentButtonItem]!
                        button.setState(isActive ? .accent : .normal)
                    }
                
                // 마감기한 방법
                if let state = stateFromVM.applyDeadlineType {
                    
                    deadlineTypeButtons
                        .enumerated()
                        .forEach { (index, button) in
                            let item = ApplyDeadlineType(rawValue: index)!
                            
                            if item == state {
                                button.setState(.accent)
                            }
                        }
                }
                
                // 마감기간
                if let state = stateFromVM.deadlineDate {
                    
                    calendarOpenButton
                        .textLabel.textString = state.convertDateToString()
                }
                
            })
            .disposed(by: disposeBag)
        
        viewModel
            .deadlineString
            .drive(onNext: { [calendarOpenButton] str in
                calendarOpenButton.textLabel.textString = str
            })
            .disposed(by: disposeBag)
        
        // Input
        
        Observable
            .merge(
                expButtons
                    .enumerated()
                    .map { (index, button) in
                        let item = ExperiencePreferenceType(rawValue: index)!
                        return button.eventPublisher
                            .compactMap { state -> ExperiencePreferenceType? in state == .accent ? item : nil }
                            .asObservable()
                    }
            )
            .map { [expButtons] (type) in
                
                expButtons
                    .enumerated()
                    .forEach { (index, button) in
                        let item = ExperiencePreferenceType(rawValue: index)!
                        if item != type {
                            button.setState(.normal)
                        }
                    }
                
                return type
            }
            .bind(to: viewModel.experiencePreferenceType)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                applyTypeButtons
                    .enumerated()
                    .map { (index, button) in
                        let item = ApplyType(rawValue: index)!
                        return button.eventPublisher
                            .map { state in (item, state == .accent) }
                            .asObservable()
                    }
            )
            .bind(to: viewModel.applyType)
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                deadlineTypeButtons
                    .enumerated()
                    .map { (index, button) in
                        let item = ApplyDeadlineType(rawValue: index)!
                        return button.eventPublisher
                            .compactMap { state -> ApplyDeadlineType? in state == .accent ? item : nil }
                            .asObservable()
                    }
            )
            .map { [deadlineTypeButtons] (type) in
                
                deadlineTypeButtons
                    .enumerated()
                    .forEach { (index, button) in
                        let item = ApplyDeadlineType(rawValue: index)!
                        if item != type {
                            button.setState(.normal)
                        }
                    }
                
                return type
            }
            .bind(to: viewModel.applyDeadlineType)
            .disposed(by: disposeBag)
        
        deadlineDate
            .bind(to: viewModel.deadlineDate)
            .disposed(by: disposeBag)
    }
}

extension ApplicationDetailViewContentView: OneDayPickerDelegate {
    public func oneDayPicker(selectedDate: Date) {
        // 위임자 패턴으로 데이터를 수신
        deadlineDate.accept(selectedDate)
    }
}
