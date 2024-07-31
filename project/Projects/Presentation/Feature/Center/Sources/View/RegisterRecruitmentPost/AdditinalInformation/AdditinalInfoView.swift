//
//  AdditinalApplicationInfoView.swift
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

public class AdditinalApplicationInfoState {
    public var preferenceAboutExp: PreferenceAboutExp = .beginnerPossible
    public var applicationMethod: ApplicationMethod = .app
    public var recruitmentDeadline: RecruitmentDeadline = .specificDate
    public var deadlineDate: Date?
    
    public init() { }
}

public protocol AdditinalApplicationInfoViewModelable {
    // Input
    var preferenceAboutExp: PublishRelay<PreferenceAboutExp> { get }
    var applicationMethod: PublishRelay<ApplicationMethod> { get }
    var recruitmentDeadline: PublishRelay<RecruitmentDeadline> { get }
    var deadlineDate: BehaviorRelay<Date> { get }
    
    // Output
    var selectedPreferenceAboutExp: Driver<PreferenceAboutExp> { get }
    var selectedApplicationMethod: Driver<ApplicationMethod> { get }
    var selectedRecruitmentDeadline: Driver<RecruitmentDeadline> { get }
    
    var completeState: Driver<AdditinalApplicationInfoState> { get }
}

public class AdditinalApplicationInfoView: UIView, RegisterRecruitmentPostViews {
    
    // Init
        
    // Not init
    private let viewModel: AdditinalApplicationInfoViewModelable = AdditinalInfoVM()
    
    // Cell type
    typealias TextCellType = CellWrapper<StateButtonTyp1>
    
    // Section Data
    let sectionData: [SectionData] = [
        SectionData(
            titleText: "경력 우대 여부",
            subData: PreferenceAboutExp.allCases.map { exp in
                CellData(cellText: exp.korTextForBtn)
            },
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "지원 방법",
            subTitle: "(다중 선택 가능)",
            subData: ApplicationMethod.allCases.map { exp in
                CellData(cellText: exp.korTextForBtn)
            },
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "접수 마감일",
            subData: RecruitmentDeadline.allCases.map { exp in
                CellData(cellText: exp.korTextForBtn)
            },
            cellSize: .init(width: 104, height: 44)
        ),
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
            .bind(to: vm.addtionalApplicationInfoState)
            .disposed(by: disposeBag)
    }
}

extension AdditinalApplicationInfoView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionData[section].subData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = sectionData[indexPath.section].subData[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
        
        // cell appearance
        cell.innerView.label.textString = cellData.cellText
        
        // binding
        let itemIndex = indexPath.item
    
        switch indexPath.section {
        case 0:
            let item = PreferenceAboutExp(rawValue: itemIndex)!
            bindRadioButtons(
                cell: cell,
                item: item,
                input: viewModel.preferenceAboutExp,
                output: viewModel.selectedPreferenceAboutExp
                )
        case 1:
            let item = ApplicationMethod(rawValue: itemIndex)!
            bindRadioButtons(
                cell: cell,
                item: item,
                input: viewModel.applicationMethod,
                output: viewModel.selectedApplicationMethod
                )
        case 2:
            let item = RecruitmentDeadline(rawValue: itemIndex)!
            bindRadioButtons(
                cell: cell,
                item: item,
                input: viewModel.recruitmentDeadline,
                output: viewModel.selectedRecruitmentDeadline
                )
        default:
            fatalError()
        }
        
        return cell
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

extension AdditinalApplicationInfoView: UICollectionViewDelegateFlowLayout {
    
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

        sectionData[indexPath.section].cellSize
    }
}

// MARK: Bind Cells
extension AdditinalApplicationInfoView {
    
    private func bindRadioButtons<T: RawRepresentable>(
        cell: TextCellType,
        item: T,
        input: PublishRelay<T>,
        output: Driver<T>
    ) where T.RawValue == Int {
        
        // Input
        cell.innerView
            .eventPublisher
            .map { $0 == .accent }
            .filter { $0 }
            .map { _ in item }
            .bind(to: input)
            .disposed(by: disposeBag)
        
        // Output
        output
            .map { currentItem in currentItem == item }
            .drive { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 번튼이 눌린 경우
                    cell.innerView.setState(.normal)
                }
            }
            .disposed(by: disposeBag)
    }
}


