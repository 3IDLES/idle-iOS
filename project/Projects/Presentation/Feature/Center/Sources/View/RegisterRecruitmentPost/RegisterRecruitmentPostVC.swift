//
//  RegisterRecruitmentPostVC.swift
//  CenterFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

enum RegisterRecruitmentPage: Int, CaseIterable {
    case workTimeAndPayment = 0
    case workPlaceAddress = 1
    case customerInformation = 2
    case customerRequirement = 3
    case additionalInfo = 4
}

public protocol RegisterRecruitmentPostViewModelable: AddressInputViewModelable {
    // Input
    
    // Output
    var alert: Driver<DefaultAlertContentVO>? { get }
}

fileprivate protocol RegisterRecruitmentPostViews: UIView {
    var ctaButton: CTAButtonType1 { get }
    func bind(viewModel vm: RegisterRecruitmentPostViewModelable)
}

extension AddressView: RegisterRecruitmentPostViews {
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        bind(viewModel: vm as AddressInputViewModelable)
    }
}

public class RegisterRecruitmentPostVC: BaseViewController {
    
    // Init
    
    // Not Init
    /// 현재 스크린의 넓이를 의미합니다.
    private var screenWidth: CGFloat {
        guard let screenWidth = view.window?.windowScene?.screen.bounds.width else {
            fatalError()
        }
        return screenWidth
    }
    
    private var pageViews: [RegisterRecruitmentPostViews] = []
    private var pagesAreSetted = false
    
    var currentIndex: Int = 0
    
    // For RC=1
    private var viewModel: RegisterRecruitmentPostViewModelable?
    
    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "공고 등록")
        return bar
    }()
    lazy var statusBar: ProcessStatusBar = {
        let view = ProcessStatusBar(
            processCount: RegisterCenterInfoPage.allCases.count,
            startIndex: 0
        )
        return view
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        // View를 생성
        // View를 여기서 생성하는 이유는 bind매서드호출시(viewDidLoad이후) view들을 바인딩 시키기 위해서 입니다.
        createPages()
        setPagesLayoutAndObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        // ViewController
        setAppearance()
        setLayout()
        setObservable()
    }
    
    /// 화면의 넓이를 안전하게 접근할 수 있는 시점, 화면 관련 속성들이 설정되어 있으므로 nil이 아닙니다.
    public override func viewDidAppear(_ animated: Bool) {
        if !pagesAreSetted {
            pagesAreSetted = true
            displayPageView()
        }
    }
    
    
    private func setAppearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    private func setLayout() {
        [
            navigationBar,
            statusBar,
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            statusBar.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 7),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setObservable() {
        // 뒤로가기 바인딩
        navigationBar
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.prev()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func createPages() {
        self.pageViews = RegisterRecruitmentPage.allCases.map { page in
            switch page {
                case .workTimeAndPayment:
                    WorkTimeAndPaymentView()
                case .workPlaceAddress:
                    WorkTimeAndPaymentView()
                case .customerInformation:
                    CustomerInformationView()
                case .customerRequirement:
                    CustomerRequirementView()
                case .additionalInfo:
                    AdditinalInformationView()
            }
        }
    }
    
    private func setPagesLayoutAndObservable() {
            
        // 레이아웃 설정
        pageViews
            .enumerated()
            .forEach { index, subView in
                view.addSubview(subView)
                subView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    subView.topAnchor.constraint(equalTo: statusBar.bottomAnchor),
                    subView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    subView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                ])
            }
        
        // 첫번째 뷰를 최상단으로
        view.bringSubviewToFront(pageViews.first!)
        
        // 옵저버블 설정
        let observables = pageViews
            .map { view in
                view.ctaButton.eventPublisher
            }
        Observable
            .merge(observables)
            .subscribe(onNext: { [weak self] _ in
                self?.next()
            })
            .disposed(by: disposeBag)
    }
    
    private func displayPageView() {
        // 뷰들을 오른쪽으로 이동
        pageViews.forEach { view in
            view.transform = .init(translationX: screenWidth, y: 0)
        }
        // 첫번째 뷰를 표시
        pageViews.first?.transform = .identity
    }
    
    private func next(animated: Bool = true) {
        
        if let nextIndex = RegisterCenterInfoPage(rawValue: currentIndex+1)?.rawValue {
            
            // Status바 이동
            statusBar.moveToSignal.onNext(.next)
            
            let prevView: UIView? = currentIndex != -1 ? pageViews[currentIndex] : nil
            let willShowView = pageViews[nextIndex]
            
            currentIndex = nextIndex
            
            UIView.animate(withDuration: animated ? 0.35 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView?.transform = .init(translationX: -screenWidth, y: 0)
                willShowView.transform = .identity
            }
        }
    }
    
    private func prev(animated: Bool = true) {
        if let nextIndex = RegisterCenterInfoPage(rawValue: currentIndex-1)?.rawValue {
            
            // Status바 이동
            statusBar.moveToSignal.onNext(.prev)
            
            let prevView = pageViews[currentIndex]
            let willShowView = pageViews[nextIndex]
            
            currentIndex = nextIndex
            
            UIView.animate(withDuration: animated ? 0.35 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView.transform = .init(translationX: screenWidth, y: 0)
                willShowView.transform = .identity
            }
        } else {
            
            // 돌아가기, Coordinator호출
        }
    }
    
    public func bind(viewModel vm: RegisterRecruitmentPostViewModelable) {
        
        // RC=1
        self.viewModel = vm
        
        // Output
        vm
            .alert?
            .drive { [weak self] vo in
                self?.showAlert(vo: vo)
            }
            .disposed(by: disposeBag)
        
        // pageView에 ViewModel을 바인딩
        pageViews
            .forEach { pv in
                pv.bind(viewModel: vm)
            }
    }
}

enum DayItem: CaseIterable {
    case mon, tue, wed, thu, fri, sat, sun
    
    var oneWordName: String {
        switch self {
        case .mon:
            "월"
        case .tue:
            "화"
        case .wed:
            "수"
        case .thu:
            "목"
        case .fri:
            "금"
        case .sat:
            "토"
        case .sun:
            "일"
        }
    }
}

public class TextItemCell: UICollectionViewCell {
    
    // Init
    
    // View
    private(set) lazy var labelButtonView: StateButtonTyp1 = {
        let btn = StateButtonTyp1(
            text: "",
            initial: .normal
        )
        btn.label.typography = .Body2
        btn.label.attrTextColor = DSKitAsset.Colors.gray500.color
        return btn
    }()
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        contentView.addSubview(labelButtonView)
        labelButtonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelButtonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            labelButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            labelButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

class DaysCollectionView: UICollectionView, UICollectionViewDelegate {
    
    typealias Cell = TextItemCell
    
    let items = DayItem.allCases
    
    let identifier = String(describing: Cell.self)
    
    public let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 40, height: 40)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        return layout
    }()
    
    init() {
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        self.dataSource = self
        self.register(Cell.self, forCellWithReuseIdentifier: identifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
extension DaysCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
        
        cell.labelButtonView.label.textString = item.oneWordName
        return cell
    }
}

// MARK: 근무시간및 급여
class WorkTimeAndPaymentView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    
    // View
    private let processTitle: IdleLabel = {
        let label = IdleLabel(typography: .Heading2)
        label.textString = "근무 시간 및 급여를 입력해주세요."
        label.textAlignment = .left
        return label
    }()
    
    private let workingDayButtons: DaysCollectionView = {
        let view = DaysCollectionView()
        view.isScrollEnabled = false
        return view
    }()
    
    
    // 하단 버튼
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
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
        
        let stacks = [
            ("근무 요일", workingDayButtons)
        ].map { (title, view) in
            
            VStack(
                [
                    {
                        let label = IdleLabel(typography: .Subtitle4)
                        label.textString = title
                        label.textAlignment = .left
                        return label
                    }(),
                    view
                ],
                spacing: 6,
                alignment: .fill
            )
        }
        
        let cellCount = workingDayButtons.items.count
        let flowLayout = workingDayButtons.flowLayout
        let cellSize = flowLayout.itemSize
        let collectionViewWidth = cellSize.width * CGFloat(cellCount) + flowLayout.minimumInteritemSpacing * CGFloat(cellCount-1)
        let stackWidth = UIScreen.main.bounds.width - (self.layoutMargins.left+self.layoutMargins.right)
        let lineCnt = Int(CGFloat(collectionViewWidth)/stackWidth) + 1
        let collectionViewHeight = CGFloat(lineCnt) * cellSize.height + CGFloat(lineCnt-1) * flowLayout.minimumLineSpacing
        
        NSLayoutConstraint.activate([
            workingDayButtons.heightAnchor.constraint(equalToConstant: collectionViewHeight)
        ])
        
        let inputStack = VStack(
            stacks,
            spacing: 28,
            alignment: .fill
        )
        
        [
            processTitle,
            inputStack,
            ctaButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        
        NSLayoutConstraint.activate([
            
            processTitle.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            processTitle.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            processTitle.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            inputStack.topAnchor.constraint(equalTo: processTitle.bottomAnchor, constant: 32),
            inputStack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            inputStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            
            ctaButton.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    private func setObservable() {
        
    }
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
    }
}


// MARK: 근무지 주소

// MARK: 고객정보
class CustomerInformationView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    
    
    // View
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
        
    }
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
    }
}

// MARK: 공객 요구사항
class CustomerRequirementView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    
    
    // View
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
        
    }
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
    }
}

// MARK: 공객 요구사항
class AdditinalInformationView: UIView, RegisterRecruitmentPostViews {
    
    // Init
    
    
    // View
    let ctaButton: CTAButtonType1 = {
        
        let button = CTAButtonType1(labelText: "다음")
        button.setEnabled(false)
        return button
    }()
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
        
    }
    
    func bind(viewModel vm: any RegisterRecruitmentPostViewModelable) {
        
    }
}
