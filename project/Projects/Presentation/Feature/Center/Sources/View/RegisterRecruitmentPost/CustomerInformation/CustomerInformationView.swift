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
    
    // Input
    var gender: PublishRelay<Gender?> { get }
    var birthYear: PublishRelay<String> { get }
    var weight: PublishRelay<String> { get }
    var careGrade: PublishRelay<CareGrade?> { get }
    var cognitionState: PublishRelay<CognitionItem?> { get }
    var deseaseDescription: BehaviorRelay<String> { get }
    
    // Output
    var selectedGender: Driver<Gender?> { get }
    var selectedCareGrade: Driver<CareGrade?> { get }
    var selectedCognitionState: Driver<CognitionItem?> { get }
    
    var completeState: Driver<CustomerInformationState?> { get }
}

public class CustomerInformationView: UIView, RegisterRecruitmentPostViews {
    
    // Init
        
    // Not init
    private let viewModel: CustomerInformationViewModelable = CustomerInformationVM()
    
    // Cell Type
    typealias TextCellType = CellWrapper<StateButtonTyp1>
    typealias TextInputCellType = CellWrapper<MultiLineTextField>
    typealias WeightInputCellType = CellWrapper<TextFieldWithDegree>
    
    // Section Data
    let sectionData: [SectionData] = [
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
            subData: CognitionItem.allCases.map { cog in
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
    
    private let disposeBag = DisposeBag()
    
    public init() {
        
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
    
    private func setObservable() { }
    
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
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
        viewModel
            .completeState
            .asObservable()
            .map { [ctaButton] state in
                ctaButton.setEnabled(state != nil)
                return state
            }
            .compactMap { $0 }
            .bind(to: vm.customerInformationState)
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
        case 0, 3, 4:
            // 성별, 요양등급, 인지상태
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            // binding
            let itemIndex = indexPath.item
            switch indexPath.section {
            case 0:
                bindGender(cell: cell, itemIndex: itemIndex)
            case 3:
                bindCareGrade(cell: cell, itemIndex: itemIndex)
            case 4:
                bindCognition(cell: cell, itemIndex: itemIndex)
            default:
                fatalError()
            }
            
            return cell
        case 1:
            // 출생연도 선택
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCellType.identifier, for: indexPath) as! TextInputCellType
            
            // cell appearance
            cell.innerView.placeholderText = cellData.cellText
            
            // binding
            bindBirthYear(cell: cell)
            
            return cell
        case 2:
            // 몸무게
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeightInputCellType.identifier, for: indexPath) as! WeightInputCellType
            
            // cell appearance
            cell.innerView.degreeLabel.textString = "kg"
            cell.innerView.textField.keyboardType = .numberPad
            cell.innerView.textField.setKeyboardAvoidance(movingView: self)
            
            // binding
            bindWeight(cell: cell)
            
            return cell
        case 5:
            // 질병
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCellType.identifier, for: indexPath) as! TextInputCellType
            
            // cell appearance
            cell.innerView.placeholderText = cellData.cellText
            cell.innerView.setKeyboardAvoidance(movingView: self)
            
            // binding
            bindDeceaseDiscription(cell: cell)
            
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
        case 0, 3, 4:
            return size
        case 1, 2, 5:
            let horizontalInset = collectionView.contentInset.left+collectionView.contentInset.right
            let width = collectionView.bounds.width - horizontalInset
            return .init(width: width, height: size.height)
        default:
            fatalError()
        }
    }
}

extension CustomerInformationView {
    
    private func bindGender(cell: TextCellType, itemIndex: Int) {
        
        let gender = Gender(rawValue: itemIndex)!
        
        // Input
        cell.innerView
            .eventPublisher
            .map { $0 == .accent }
            .filter { $0 }
            .map { _ in gender }
            .bind(to: viewModel.gender)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .selectedGender
            .map { currentItem in currentItem == gender }
            .drive { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 번튼이 눌린 경우
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
    
    private func bindCareGrade(cell: TextCellType, itemIndex: Int) {
        
        let grade = CareGrade(rawValue: itemIndex)!
        
        // Input
        cell.innerView
            .eventPublisher
            .map { $0 == .accent }
            .filter { $0 }
            .map { _ in grade }
            .bind(to: viewModel.careGrade)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .selectedCareGrade
            .map { currentItem in currentItem == grade }
            .drive { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 번튼이 눌린 경우
                    cell.innerView.setState(.normal)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindCognition(cell: TextCellType, itemIndex: Int) {
        
        let cogItem = CognitionItem(rawValue: itemIndex)!
        
        // Input
        cell.innerView
            .eventPublisher
            .map { $0 == .accent }
            .filter { $0 }
            .map { _ in cogItem }
            .bind(to: viewModel.cognitionState)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .selectedCognitionState
            .map { currentItem in currentItem == cogItem }
            .drive { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 번튼이 눌린 경우
                    cell.innerView.setState(.normal)
                }
            }
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

