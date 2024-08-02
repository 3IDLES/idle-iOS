//
//  CustomerRequirementView.swift
//  CenterFeature
//
//  Created by choijunios on 7/30/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public protocol CustomerRequirementViewModelable {
    // Input
    var mealSupportNeeded: PublishRelay<Bool> { get }
    var toiletSupportNeeded: PublishRelay<Bool> { get }
    var movingSupportNeeded: PublishRelay<Bool> { get }
    
    var dailySupportTypeNeeded: PublishRelay<(DailySupportType, Bool)> { get }
    var additionalRequirement: PublishRelay<String> { get }
    
    // Output
    var isMealSupportActvie: Driver<Bool> { get }
    var isToiletSupportActvie: Driver<Bool> { get }
    var isMovingSupportActvie: Driver<Bool> { get }
    
    var completeState: Driver<CustomerRequirementState> { get }
}

public class CustomerRequirementView: UIView, RegisterRecruitmentPostViews {
    
    // Init
        
    // Not init
    private let viewModel: CustomerRequirementViewModelable = CustomerRequirementVM()
    
    // Cell type
    typealias TextCellType = CellWrapper<StateButtonTyp1>
    typealias TextInputCellType = CellWrapper<MultiLineTextField>
    
    // Section Data
    let sectionData: [SectionData] = [
        SectionData(
            titleText: "식사보조",
            subData: [
                CellData(cellText: "필요"),
                CellData(cellText: "불필요"),
            ],
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "배변보조",
            subData: [
                CellData(cellText: "필요"),
                CellData(cellText: "불필요"),
            ],
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "이동보조",
            subData: [
                CellData(cellText: "필요"),
                CellData(cellText: "불필요"),
            ],
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "일상보조",
            subTitle: "(선택, 다중 선택 가능)",
            subData: DailySupportType.allCases.map { CellData(cellText: $0.korLetterTextForBtn) },
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "이외에도 요구사항이 있다면 적어주세요.",
            subTitle: "(선택)",
            subData: [ 
                CellData(cellText: "추가적으로 요구사항이 있다면 작성해주세요.")
            ],
            cellSize: .heightOnly(156)
        )
    ]
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "고객 요구사항을 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    private let collectionView: UICollectionView = {
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
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
        
        collectionView.isScrollEnabled = true
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 32, right: 20)
    }
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
        viewModel
            .completeState
            .asObservable()
            .map { [ctaButton] state in
                ctaButton.setEnabled(true)
                return state
            }
            .bind(to: vm.customerRequirementState)
            .disposed(by: disposeBag)
    }
}

extension CustomerRequirementView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionData[section].subData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (0...3).contains(indexPath.section) {
            
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            cell.innerView.label.textString = cellData.cellText
            
            switch indexPath.section {
            case 0:
                bindMealSupport(cell: cell, state: indexPath.item == 0 ? .active : .inactive)
            case 1:
                bindToiletSupport(cell: cell, state: indexPath.item == 0 ? .active : .inactive)
            case 2:
                bindMovingSupport(cell: cell, state: indexPath.item == 0 ? .active : .inactive)
            case 3:
                bindDailySupport(cell: cell, index: indexPath.item)
            default:
                fatalError()
            }
            
            return cell
        } else if indexPath.section == 4 {
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCellType.identifier, for: indexPath) as! TextInputCellType
            
            // Apearance
            cell.innerView.placeholderText = cellData.cellText
            cell.innerView.setKeyboardAvoidance(movingView: self)
            
            return cell
        } else {
            // 섹션에 대한 셀이 정의되지 않음
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

extension CustomerRequirementView: UICollectionViewDelegateFlowLayout {
    
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
        
        if indexPath.section == 4 {
            let horizontalInset = collectionView.contentInset.left+collectionView.contentInset.right
            let width = collectionView.bounds.width - horizontalInset
            return .init(
                width: collectionView.bounds.width,
                height: size.height
            )
        }
        
        return size
    }
}

// MARK: Bind Cells
extension CustomerRequirementView {
    
    enum RadioBtnState {
        case active, inactive
    }
    
    private func bindMealSupport(cell: TextCellType, state: RadioBtnState) {
        bindRadioBtn(cell: cell, state: state,
            input: viewModel.mealSupportNeeded,
            output: viewModel.isMealSupportActvie
        )
    }
    
    private func bindToiletSupport(cell: TextCellType, state: RadioBtnState) {
        bindRadioBtn(cell: cell, state: state,
            input: viewModel.toiletSupportNeeded,
            output: viewModel.isToiletSupportActvie
        )
    }
    
    private func bindMovingSupport(cell: TextCellType, state: RadioBtnState) {
        bindRadioBtn( cell: cell, state: state,
            input: viewModel.movingSupportNeeded,
            output: viewModel.isMovingSupportActvie
        )
    }
    private func bindRadioBtn(cell: TextCellType, state: RadioBtnState, input: PublishRelay<Bool>, output: Driver<Bool>) {
        
        // input
        cell
            .innerView
            .eventPublisher
            .filter { $0 == .accent }
            .map { _ in state == .active }
            .bind(to: input)
            .disposed(by: disposeBag)
        
        // Output
        output
            .filter { isActive in
                if state == .active {
                    // 비활성화 버튼이 눌린 경우 true가 반환되고 스트림이 계속 진행됩니다.
                    return !isActive
                } else {
                    // 활성화 버튼이 눌린 경우 true가 반환되고 스트림이 계속 진행됩니다.
                    return isActive
                }
            }
            .drive { [cell] _ in
                cell.innerView.setState(.normal)
            }
    }
    
    private func bindDailySupport(cell: TextCellType, index: Int) {
        
        let type = DailySupportType(rawValue: index)!
        
        // Input
        cell
            .innerView
            .eventPublisher
            .map { (type, $0 == .accent) }
            .bind(to: viewModel.dailySupportTypeNeeded)
            .disposed(by: disposeBag)    
    }
    
    private func bindAdditionalInfo(cell: TextInputCellType) {
        // Input
        cell
            .innerView
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.additionalRequirement)
            .disposed(by: disposeBag)
    }
}


