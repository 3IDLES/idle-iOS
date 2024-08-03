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
    var deseaseDescription: PublishRelay<String> { get }
    
    var customerInformationStateObject: Driver<CustomerInformationStateObject> { get }
    var customerInformationNextable: Driver<Bool> { get }
}

public class CustomerInformationView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    public var viewModel: CustomerInformationViewModelable
        
    // Not init
    
    
    // Cell Type
    typealias TextCellType = CellWrapper<StateButtonTyp1>
    typealias TextInputCellType = CellWrapper<MultiLineTextField>
    typealias WeightInputCellType = CellWrapper<TextFieldWithDegree>
    
    // Section Data
    let sectionData: [SectionData] = [
        SectionData(
            titleText: "이름",
            subData: [
                CellData(cellText: "고객의 이름을 입력해주세요.")
            ],
            cellSize: .heightOnly(44)
        ),
        SectionData(
            titleText: "성별",
            subData: [Gender.male, Gender.female].map { gender in
                CellData(cellText: gender.twoLetterKoreanWord)
            },
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "출생연도",
            subData: [
                CellData(cellText: "고객의 출생연도를 입력해주세요. (예: 1965)")
            ],
            cellSize: .heightOnly(44)
        ),
        SectionData(
            titleText: "몸무게",
            subData: [
                .emptyCell
            ],
            cellSize: .heightOnly(44)
        ),
        SectionData(
            titleText: "요양 등급",
            subData: CareGrade.allCases.map { grade in
                CellData(cellText: grade.textForCellBtn)
            },
            cellSize: .init(width: 40, height: 40)
        ),
        SectionData(
            titleText: "인지 상태",
            subData: CognitionDegree.allCases.map { cog in
                CellData(cellText: cog.korTextForCellBtn)
            },
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "질병",
            subTitle: "(선택)",
            subData: [
                CellData(cellText: "고객이 현재 앓고 있는 질병 또는 병력을 입력해주세요.")
            ],
            cellSize: .init(width: 104, height: 44)
        )
    ]
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "고객 정보를 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    private let collectionView: UICollectionView = {
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)

        return view
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
    
    public init(viewModel: CustomerInformationViewModelable) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        
        setAppearance()
        setLayout()
        setObservable()
        
        setCollectionView()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        self.backgroundColor = .clear
        self.layoutMargins = .init(top: 32, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        
        [
            processTitle,
            collectionView,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    private func setCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Header
        collectionView.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderView.identifier)
        
        // Cell
        collectionView.register(TextCellType.self, forCellWithReuseIdentifier: TextCellType.identifier)
        collectionView.register(TextInputCellType.self, forCellWithReuseIdentifier: TextInputCellType.identifier)
        collectionView.register(WeightInputCellType.self, forCellWithReuseIdentifier: WeightInputCellType.identifier)
        
        collectionView.isScrollEnabled = true
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 32, right: 20)
    }
    
    private func setObservable() {
        
        viewModel
            .customerInformationNextable
            .drive(onNext: { [ctaButton] isNextable in
                ctaButton.setEnabled(isNextable)
            })
            .disposed(by: disposeBag)
    }
}

extension CustomerInformationView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionData[section].subData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            // 이름 입력
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCellType.identifier, for: indexPath) as! TextInputCellType
            
            // cell appearance
            cell.innerView.placeholderText = cellData.cellText
            
            // binding
            bindName(cell: cell)
                
            // 초기값 설정
            viewModel
                .customerInformationStateObject
                .drive(onNext: { [weak cell] state in
                    let name = state.name
                    if !name.isEmpty {
                        cell?.innerView.textString = name
                    }
                })
                .disposed(by: disposeBag)
            
            return cell
        case 1, 4, 5:
            // 성별, 요양등급, 인지상태
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            // binding
            let itemIndex = indexPath.item
            switch indexPath.section {
            case 1:
                let item = Gender(rawValue: itemIndex)!
                bindRadioButtons(
                    cell: cell,
                    item: item,
                    viewInput: selectedGender,
                    vmInput: viewModel.gender
                )
                
                // 초기값 설정
                viewModel
                    .customerInformationStateObject
                    .drive(onNext: { [weak cell] state in
                        cell?.innerView.setState(state.gender == item ? .accent : .normal)
                    })
                    .disposed(by: disposeBag)
            case 4:
                let item = CareGrade(rawValue: itemIndex)!
                bindRadioButtons(
                    cell: cell,
                    item: item,
                    viewInput: selectedCareGrade,
                    vmInput: viewModel.careGrade
                )
                
                // 초기값 설정
                viewModel
                    .customerInformationStateObject
                    .drive(onNext: { [weak cell] state in
                        cell?.innerView.setState(state.careGrade == item ? .accent : .normal)
                    })
                    .disposed(by: disposeBag)
            case 5:
                let item = CognitionDegree(rawValue: itemIndex)!
                bindRadioButtons(
                    cell: cell,
                    item: item,
                    viewInput: selectedCognitionState,
                    vmInput: viewModel.cognitionState
                )
                
                // 초기값 설정
                viewModel
                    .customerInformationStateObject
                    .drive(onNext: { [weak cell] state in
                        cell?.innerView.setState(state.cognitionState == item ? .accent : .normal)
                    })
                    .disposed(by: disposeBag)
            default:
                fatalError()
            }
            
            return cell
        case 2:
            // 출생연도 선택
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCellType.identifier, for: indexPath) as! TextInputCellType
            
            // cell appearance
            cell.innerView.placeholderText = cellData.cellText
            cell.innerView.keyboardType = .numberPad
            cell.innerView.isScrollEnabled = false
            cell.innerView.setKeyboardAvoidance(movingView: self)
            
            // binding
            bindBirthYear(cell: cell)
            
            // 초기값 설정
            viewModel
                .customerInformationStateObject
                .drive(onNext: { [weak cell] state in
                    let birthYear = state.birthYear
                    if !birthYear.isEmpty {
                        cell?.innerView.textString = birthYear
                    }
                })
                .disposed(by: disposeBag)
            
            return cell
        case 3:
            // 몸무게
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeightInputCellType.identifier, for: indexPath) as! WeightInputCellType
            
            // cell appearance
            cell.innerView.degreeLabel.textString = "kg"
            cell.innerView.textField.keyboardType = .numberPad
            cell.innerView.setKeyboardAvoidance(movingView: self)
            
            // binding
            bindWeight(cell: cell)
            
            // 초기값 설정
            viewModel
                .customerInformationStateObject
                .drive(onNext: { [weak cell] state in
                    let weight = state.weight
                    if !weight.isEmpty {
                        cell?.innerView.textField.textString = weight
                    }
                })
                .disposed(by: disposeBag)
            
            return cell
        case 6:
            // 질병
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCellType.identifier, for: indexPath) as! TextInputCellType
            
            // cell appearance
            cell.innerView.placeholderText = cellData.cellText
            cell.innerView.setKeyboardAvoidance(movingView: self)
            
            // binding
            bindDeceaseDiscription(cell: cell)
            
            // 초기값 설정
            viewModel
                .customerInformationStateObject
                .drive(onNext: { [weak cell] state in
                    let decease = state.deceaseDescription
                    if !decease.isEmpty {
                        cell?.innerView.textString = decease
                    }
                })
                .disposed(by: disposeBag)
            
            return cell
            
        default:
            // 구현되지 않음
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderView.identifier, for: indexPath) as! TitleHeaderView
            
            header.titleLabel.textString = sectionData[indexPath.section].titleText
            header.subTitleLabel.textString = sectionData[indexPath.section].subTitle ?? ""
            
            return header
        }
        return UICollectionReusableView()
    }
}

extension CustomerInformationView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // 헤더의 크기 설정
        return CGSize(width: collectionView.bounds.width, height: 22)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        // 헤더와 섹션 간의 간격을 설정
        let bottomInset: CGFloat = section != (sectionData.count-1) ? 28 : 0
        return UIEdgeInsets(top: 6, left: 0, bottom: bottomInset, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sectionData[indexPath.section].cellSize
        
        switch indexPath.section {
        case 1, 4, 5:
            return size
        case 0, 2, 3, 6:
            let horizontalInset = collectionView.contentInset.left+collectionView.contentInset.right
            let width = collectionView.bounds.width - horizontalInset
            return .init(width: width, height: size.height)
        default:
            fatalError()
        }
    }
}

extension CustomerInformationView {
    
    private func bindName(cell: TextInputCellType) {
        
        // Input
        cell
            .innerView
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
    }
    
    private func bindRadioButtons<T: RawRepresentable>(
        cell: TextCellType,
        item: T,
        viewInput: PublishRelay<T>,
        vmInput: PublishRelay<T>
    ) where T.RawValue == Int {
        
        // Input
        let selectedItem = cell.innerView
            .eventPublisher
            .map { $0 == .accent }
            .filter { $0 }
            .map { _ in item }
            .share()
        
        selectedItem
            .bind(to: vmInput)
            .disposed(by: disposeBag)
        
        selectedItem
            .bind(to: viewInput)
            .disposed(by: disposeBag)
        
        // Output
        viewInput
            .observe(on: MainScheduler.instance)
            .map { currentItem in currentItem == item }
            .subscribe { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 버튼이 눌린 경우
                    cell.innerView.setState(.normal)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindBirthYear(cell: TextInputCellType) {
        
        // Input
        cell
            .innerView
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.birthYear)
            .disposed(by: disposeBag)
    }
    
    private func bindWeight(cell: WeightInputCellType) {
        
        // Input
        cell.innerView
            .edtingText
            .asObservable()
            .bind(to: viewModel.weight)
            .disposed(by: disposeBag)
    }
    
    private func bindDeceaseDiscription(cell: TextInputCellType) {
        
        // Input
        cell.innerView
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.deseaseDescription)
            .disposed(by: disposeBag)
    }
}

