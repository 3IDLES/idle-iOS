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
    public var preferenceAboutExp: PreferenceAboutExp?
    public var applicationMethod: ApplicationMethod?
    public var recruitmentDeadline: RecruitmentDeadline?
    public var deadlineDate: Date?
    
    public init() { }
}

public protocol AdditinalApplicationInfoViewModelable {
    // Input
    var preferenceAboutExp: PublishRelay<PreferenceAboutExp?> { get }
    var applicationMethod: PublishRelay<ApplicationMethod?> { get }
    var recruitmentDeadline: PublishRelay<RecruitmentDeadline?> { get }
    var deadlineDate: BehaviorRelay<Date?> { get }
    
    // Output
    var selectedPreferenceAboutExp: Driver<PreferenceAboutExp?> { get }
    var selectedApplicationMethod: Driver<ApplicationMethod?> { get }
    var selectedRecruitmentDeadline: Driver<RecruitmentDeadline?> { get }
    var selectedDateString: Driver<String?> { get }
    
    var completeState: Driver<AdditinalApplicationInfoState?> { get }
}

public class AdditinalApplicationInfoView: UIView, RegisterRecruitmentPostViews {
    
    // Init
        
    // Not init
    private let viewModel: AdditinalApplicationInfoViewModelable = AdditinalInfoVM()
    public weak var viewController: UIViewController?
    
    // Cell type
    typealias TextCellType = CellWrapper<StateButtonTyp1>
    typealias DateCellType = CellWrapper<CalendarOpenButton>
    
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
        SectionData(
            titleText: "접수마감 날짜 선택",
            subData: [ .emptyCell ],
            cellSize: .heightOnly(44)
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
    
    public init(viewController: UIViewController) {
        
        self.viewController = viewController
        
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
        collectionView.register(DateCellType.self, forCellWithReuseIdentifier: DateCellType.identifier)
        
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 32, right: 20)
    }
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
        viewModel
            .completeState
            .asObservable()
            .map { [ctaButton] state in
                // state가 유효한 경우 cta버튼을 활성화
                ctaButton.setEnabled(state != nil)
                return state
            }
            .compactMap { $0 }
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
        
        // binding
        let itemIndex = indexPath.item
    
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            let item = PreferenceAboutExp(rawValue: itemIndex)!
            bindRadioButtons(
                cell: cell,
                item: item,
                input: viewModel.preferenceAboutExp,
                output: viewModel.selectedPreferenceAboutExp
                )
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            let item = ApplicationMethod(rawValue: itemIndex)!
            bindRadioButtons(
                cell: cell,
                item: item,
                input: viewModel.applicationMethod,
                output: viewModel.selectedApplicationMethod
                )
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            let item = RecruitmentDeadline(rawValue: itemIndex)!
            bindRadioButtons(
                cell: cell,
                item: item,
                input: viewModel.recruitmentDeadline,
                output: viewModel.selectedRecruitmentDeadline
                )
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCellType.identifier, for: indexPath) as! DateCellType
            cell.isHidden = true
            
            bindDateSelect(cell: cell)
            
            return cell
        default:
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

extension AdditinalApplicationInfoView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // 헤더의 크기 설정
        switch section {
        case 0, 1, 2:
            return CGSize(width: collectionView.contentSize.width, height: 22)
        case 3:
            return .zero
        default:
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // 헤더와 섹션 간의 간격을 설정
        var bottomInset: CGFloat!
        
        switch section {
        case 0,1:
            bottomInset = 28
        case 2:
            bottomInset = 12
        default:
            bottomInset = 0
        }
        
        return UIEdgeInsets(top: 6, left: 0, bottom: bottomInset, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = sectionData[indexPath.section].cellSize
        
        switch indexPath.section {
        case 0, 1, 2:
            return size
        case 3:
            let horizontalInset = collectionView.contentInset.left+collectionView.contentInset.right
            let width = collectionView.bounds.width - horizontalInset
            return .init(width: width, height: size.height)
        default:
            fatalError()
        }
    }
}

// MARK: Bind Cells
extension AdditinalApplicationInfoView {
    
    private func bindRadioButtons<T: RawRepresentable>(
        cell: TextCellType,
        item: T,
        input: PublishRelay<T?>,
        output: Driver<T?>
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
            .compactMap { $0 }
            .map { currentItem in currentItem == item }
            .drive { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 번튼이 눌린 경우
                    cell.innerView.setState(.normal)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindDateSelect(cell: DateCellType) {
                
        // Input
        cell
            .innerView
            .rx
            .tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                
                let dataPickerVC = OneDayPickerViewController()
                dataPickerVC.modalPresentationStyle = .overFullScreen
                dataPickerVC.delegate = self
                viewController?.present(dataPickerVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .selectedRecruitmentDeadline
            .compactMap { $0 }
            .map { type in
                let isSpecific = type == .specificDate
                return !isSpecific
            }
            .drive(cell.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel
            .selectedDateString
            .compactMap { $0 }
            .map { [cell] dateStr in
                cell.innerView.textLabel.attrTextColor = DSKitAsset.Colors.gray900.color
                return dateStr
            }
            .drive(cell.innerView.textLabel.rx.textString)
            .disposed(by: disposeBag)
    }
}


extension AdditinalApplicationInfoView: OneDayPickerDelegate {
    public func oneDayPicker(selectedDate: Date) {
        // 위임자 패턴으로 데이터를 수신
        viewModel.deadlineDate.accept(selectedDate)
    }
}
