//
//  EntetPersonalInfoViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import RxSwift
import RxCocoa
import DSKit
import Entity
import PresentationCore
import BaseFeature

protocol WorkerPersonalInfoInputable: EnterNameInputable, SelectGenderInputable {
    var edtingBirthYear: PublishRelay<Int> { get }
}

protocol WorkerPersonalInfoOutputable: EnterNameOutputable, SelectGenderOutputable {
    var edtingBirthYearValidation: Driver<Bool>? { get set }
}

class EntetPersonalInfoViewController<T: ViewModelType>: BaseViewController
where T.Input: WorkerPersonalInfoInputable & PageProcessInputable,
      T.Output: WorkerPersonalInfoOutputable, T: BaseViewModel
{
    
    // View
    
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        
        label.textString = "본인의 인적사항을 입력해주세요."
        
        return label
    }()
    
    // MARK: 성함 View
    private let nameField: IFType2 = {
        let textField = IFType2(
            titleLabelText: "이름",
            placeHolderText: "성함을 입력해주세요."
        )
        return textField
    }()
    
    // MARK: 생년 View
    private let birthYearField: IFType2 = {
       
        let textField = IFType2(
            titleLabelText: "출생연도",
            placeHolderText: "출생연도를 입력해주세요. (예: 1965)",
            keyboardType: .numberPad
        )
        
        return textField
    }()
    
    // MARK: 성별 View
    private let femaleButton: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: "여성",
            initial: .normal
        )
        return btn
    }()
    
    private let maleButton: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: "남성",
            initial: .normal
        )
        return btn
    }()
    
    private let buttonContainer = PrevOrNextContainer()
    
    public init(viewModel: T) {

        super.init(nibName: nil, bundle: nil)
        
        self.bind(viewModel: viewModel)
        
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    func setAppearance() {
        self.view.backgroundColor = .white
        view.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setAutoLayout() {
        let genderButtonStack = VStack(
            [
                {
                    let label = IdleLabel(typography: .Subtitle4)
                    label.textString = "성별"
                    label.attrTextColor = DSKitAsset.Colors.gray500.color
                    return label
                }(),
                HStack([femaleButton,maleButton], spacing: 4)
            ],
            spacing: 6,
            alignment: .leading
        )
        NSLayoutConstraint.activate([
            femaleButton.heightAnchor.constraint(equalToConstant: 44),
            femaleButton.widthAnchor.constraint(equalToConstant: 104),
            
            maleButton.widthAnchor.constraint(equalTo: femaleButton.widthAnchor),
            maleButton.heightAnchor.constraint(equalTo: femaleButton.heightAnchor),
        ])
        
        [
            processTitle,
            nameField,
            birthYearField,
            genderButtonStack,
            buttonContainer
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            nameField.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            nameField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            birthYearField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 28),
            birthYearField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            birthYearField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            genderButtonStack.topAnchor.constraint(equalTo: birthYearField.bottomAnchor, constant: 28),
            genderButtonStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            genderButtonStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            buttonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            buttonContainer.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            buttonContainer.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
        ])
    }
    
    private func setObservable() {
        
        // - CTA버튼 비활성화
        guard let viewModel = self.viewModel as? T else { return }
        
        let input = viewModel.input
        
        nameField
            .eventPublisher
            .compactMap { $0 }
            .bind(to: input.editingName)
            .disposed(by: disposeBag)
        
        birthYearField
            .eventPublisher
            .compactMap { $0 }
            .compactMap { Int($0) }
            .bind(to: input.edtingBirthYear)
            .disposed(by: disposeBag)
        
        let femaleClicked = femaleButton.eventPublisher
            .filter({ $0 == .accent })
            .map { [weak self] _ in
            self?.maleButton.setState(.normal, withAnimation: false)
            return Gender.female
        }
        
        let maleClicked = maleButton.eventPublisher
            .filter({ $0 == .accent })
            .map { [weak self] _ in
            self?.femaleButton.setState(.normal, withAnimation: false)
            return Gender.male
        }
        
        Observable
            .merge(femaleClicked, maleClicked)
            .bind(to: viewModel.input.selectingGender)
            .disposed(by: disposeBag)
            
        // MARK: Output
        let output = viewModel.output
        
        let nameValidation = output.nameValidation?.asObservable() ?? .empty()
        let birthYearValidation = output.edtingBirthYearValidation?.asObservable() ?? .empty()
        let genderIsSelected = output.genderIsSelected?.asObservable() ?? .empty()
        
        Observable
            .combineLatest(
                nameValidation,
                birthYearValidation,
                genderIsSelected
            )
            .map { $0 && $1 && $2 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isAllValid in
                self?.buttonContainer.nextButton.setEnabled(isAllValid)
            })
            .disposed(by: disposeBag)
        
        // MARK: ViewController한정 로직
        // CTA버튼 클릭시 화면전환
        buttonContainer.prevBtnClicked
            .asObservable()
            .bind(to: input.nextButtonClicked)
            .disposed(by: disposeBag)
        
        buttonContainer.nextBtnClicked
            .asObservable()
            .bind(to: input.nextButtonClicked)
            .disposed(by: disposeBag)
    }
}
