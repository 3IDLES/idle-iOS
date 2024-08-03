//
//  WorkTimeAndPayView.swift
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
 
public protocol WorkTimeAndPayViewModelable {
    var selectedDay: PublishRelay<(WorkDay, Bool)> { get }
    var workStartTime: PublishRelay<String> { get }
    var workEndTime: PublishRelay<String> { get }
    var paymentType: PublishRelay<PaymentType> { get }
    var paymentAmount: PublishRelay<String> { get }
    
    var workTimeAndPayStateObject: Driver<WorkTimeAndPayStateObject> { get }
    var workTimeAndPayNextable: Driver<Bool> { get }
}

public class WorkTimeAndPayView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    public var viewModel: WorkTimeAndPayViewModelable
        
    // Not init
    
    // Cell Type
    typealias TextCellType = CellWrapper<StateButtonTyp1>
    typealias TimePickerCellType = CellWrapper<WorkTimePicker>
    typealias PaymentInputCellType = CellWrapper<TextFieldWithDegree>
    
    // Section Data
    let sectionData: [SectionData] = [
        SectionData(
            titleText: "근무 요일",
            subData: WorkDay.allCases.map { CellData(cellText: $0.korOneLetterText) },
            cellSize: .init(width: 40, height: 40)
        ),
        SectionData(
            titleText: "근무 시간",
            subData: [ 
                CellData(cellText: "시작시간"),
                CellData(cellText: "종료시간"),
            ],
            cellSize: .heightOnly(44)
        ),
        SectionData(
            titleText: "급여",
            subData: PaymentType.allCases.map { CellData(cellText: $0.korLetterText) },
            cellSize: .init(width: 104, height: 44)
        ),
        SectionData(
            titleText: "",
            subData: [
                // 급여 입력셀
                .emptyCell
            ],
            cellSize: .heightOnly(44)
        )
    ]
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "근무 시간 및 급여를 입력해주세요."
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
    
    private let selectedPaymentType: PublishRelay<PaymentType> = .init()
    
    private let disposeBag = DisposeBag()
    
    public init(viewModel: WorkTimeAndPayViewModelable) {
        
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
        collectionView.register(TimePickerCellType.self, forCellWithReuseIdentifier: TimePickerCellType.identifier)
        collectionView.register(PaymentInputCellType.self, forCellWithReuseIdentifier: PaymentInputCellType.identifier)
        
        collectionView.isScrollEnabled = true
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 32, right: 20)
    }
    
    private func setObservable() {
        
        viewModel
            .workTimeAndPayNextable
            .drive(onNext: { [ctaButton] isNextable in
                ctaButton.setEnabled(isNextable)
            })
            .disposed(by: disposeBag)
    }
}

extension WorkTimeAndPayView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionData[section].subData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            // 근무 요일 선택
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            // binding
            bindDay(cell: cell, itemIndex: indexPath.item)
            
            let item = WorkDay(rawValue: indexPath.item)!
            
            // 초기값 설정
            viewModel
                .workTimeAndPayStateObject
                .drive(onNext: { [weak cell] state in
                    cell?.innerView.setState(state.selectedDays[item] == true ? .accent : .normal)
                })
                .disposed(by: disposeBag)
            
            return cell
        case 1:
            // 근무시간 선택
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimePickerCellType.identifier, for: indexPath) as! TimePickerCellType
            
            // cell appearance
            cell.innerView.placeholderText = cellData.cellText
            
            // binding
            bindWorkTime(cell: cell, itemIndex: indexPath.item)

            // 초기값 설정
            viewModel
                .workTimeAndPayStateObject
                .drive(onNext: { [weak cell] state in
                    let timeString = indexPath.item == 0 ? state.workStartTime : state.workEndTime
                    
                    if !timeString.isEmpty {
                        cell?.innerView.textLabel.textString = timeString
                    }
                })
                .disposed(by: disposeBag)
            
            return cell
        case 2:
            // 급여 타입 선택
            let cellData = sectionData[indexPath.section].subData[indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellType.identifier, for: indexPath) as! TextCellType
            
            // cell appearance
            cell.innerView.label.textString = cellData.cellText
            
            // binding
            bindPaymentType(cell: cell, itemIndex: indexPath.item)
            
            let item = PaymentType(rawValue: indexPath.item)!
            
            // 초기값 설정
            viewModel
                .workTimeAndPayStateObject
                .drive(onNext: { [weak cell] state in
                    cell?.innerView.setState(state.paymentType == item ? .accent : .normal)
                })
                .disposed(by: disposeBag)
            
            return cell
            
        case 3:
            // 급여 입력
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentInputCellType.identifier, for: indexPath) as! PaymentInputCellType
            
            // cell appearance
            cell.innerView.degreeLabel.textString = "원"
            cell.innerView.setKeyboardAvoidance(movingView: self)
            
            // binding
            bindPaymentAmount(cell: cell)
            
            // 초기값 설정
            viewModel
                .workTimeAndPayStateObject
                .drive(onNext: { [weak cell] state in
                    cell?.innerView.textField.textString = state.paymentAmount
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

extension WorkTimeAndPayView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // 헤더가 없는 섹션
        if section == 3 { return .zero }
        
        // 헤더의 크기 설정
        return CGSize(width: collectionView.bounds.width, height: 22)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        // 헤더가 없는 섹션
        if section == 3 { return .zero }
        
        // 헤더와 섹션 간의 간격을 설정, 마지막 섹션이 아닌 경우 바텀 인셋 설정
        switch section {
        case 0,1:
            let bottomInset: CGFloat = 28.0
            return .init(top: 6, left: 0, bottom: bottomInset, right: 0)
        case 2:
            let bottomInset: CGFloat = 12.0
            return .init(top: 6, left: 0, bottom: bottomInset, right: 0)
        case 3:
            return .zero
        default:
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sectionData[indexPath.section].cellSize
        
        switch indexPath.section {
        case 0, 2:
            return size
        case 1:
            // 2개의 셀이 각각 절반의 영역을 차지합니다.
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let space = collectionView.bounds.width - flowLayout.minimumInteritemSpacing
            return .init(width: space/2, height: size.height)
        case 3:
            let horizontalInset = collectionView.contentInset.left+collectionView.contentInset.right
            let width = collectionView.bounds.width - horizontalInset
            return .init(width: width, height: size.height)
        default:
            fatalError()
        }
    }
}

extension WorkTimeAndPayView {
    
    func bindDay(cell: TextCellType, itemIndex: Int) {
        let day = WorkDay(rawValue: itemIndex)!
        
        // Input
        cell.innerView
            .eventPublisher
            .map { state in
                let isActive = state == .accent
                return (day, isActive)
            }
            .bind(to: viewModel.selectedDay)
            .disposed(by: disposeBag)
    }
    
    func bindWorkTime(cell: TimePickerCellType, itemIndex: Int) {
        
        if itemIndex == 0 {
            // 시작시간
            cell.innerView.pickedDateString
                .map { $0.toString }
                .bind(to: viewModel.workStartTime)
                .disposed(by: disposeBag)
        }
        else if itemIndex == 1 {
            // 종료시간
            cell.innerView.pickedDateString
                .map { $0.toString }
                .bind(to: viewModel.workEndTime)
                .disposed(by: disposeBag)
        }
    }
    
    func bindPaymentType(
        cell: TextCellType,
        itemIndex: Int) {
        
        let payType = PaymentType(rawValue: itemIndex)!
        
        // Input
        let selectedItem = cell.innerView
            .eventPublisher
            .map { $0 == .accent }
            .filter { $0 }
            .map { _ in payType }
            .share()
        
        selectedItem
            .bind(to: viewModel.paymentType)
            .disposed(by: disposeBag)
            
        selectedItem
            .bind(to: selectedPaymentType)
            .disposed(by: disposeBag)
        
        // Output
        selectedPaymentType
            .map { currentItem in currentItem == payType }
            .observe(on: MainScheduler.instance)
            .subscribe { isMatched in
                if !isMatched {
                    // 현재 버튼과 다른 버튼이 눌린 경우
                    cell.innerView.setState(.normal)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func bindPaymentAmount(cell: PaymentInputCellType) {
        
        // Input
        cell
            .innerView
            .edtingText
            .asObservable()
            .bind(to: viewModel.paymentAmount)
            .disposed(by: disposeBag)
    }
}
