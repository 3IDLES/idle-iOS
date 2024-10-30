//
//  RegisterRecruitmentPostVC.swift
//  CenterFeature
//
//  Created by choijunios on 7/29/24.
//

import UIKit
import BaseFeature
import Logger
import PresentationCore
import Domain
import DSKit
import Core


import RxCocoa
import RxSwift

public protocol RegisterRecruitmentPostVMBindable {
    func bind(viewModel: RegisterRecruitmentPostViewModelable)
}

public protocol RegisterRecruitmentPostViewModelable:
    
    // 수정화면 요구사항
    EditPostViewModelable,

    // 오버뷰 화면 요구 사항
    PostOverviewViewModelable
{
    func showOverView()
    func exit()
}

public class CreatePostViewController: BaseViewController {
    
    @Injected var logger: Logger
    
    /// 현재 스크린의 넓이를 의미합니다.
    private var screenWidth: CGFloat {
        guard let screenWidth = view.window?.windowScene?.screen.bounds.width else {
            fatalError()
        }
        return screenWidth
    }
    
    private var pageViews: [RegisterRecruitmentPostViews] = []
    private var pagesAreSetted = false
    
    var currentStage: RegisterRecruitmentPage = .workTimeAndPayment
    
    let exitEvent: PublishSubject<Void> = .init()

    // View
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "공고 등록")
        return bar
    }()
    lazy var statusBar: ProcessStatusBar = {
        let view = ProcessStatusBar(
            processCount: RegisterRecruitmentPage.allCases.count,
            startIndex: 0
        )
        return view
    }()
    
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
        view.clipsToBounds = true
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
            .bind(to: exitEvent)
            .disposed(by: disposeBag)
    }
    
    private func createPages() {
        self.pageViews = RegisterRecruitmentPage.stages.map { page in
            switch page {
                case .workTimeAndPayment:
                    WorkTimeAndPayView()
                case .workPlaceAddress:
                    AddressView(viewController: self)
                case .customerInformation:
                    CustomerInformationView()
                case .customerRequirement:
                    CustomerRequirementView()
                case .additionalInfo:
                    ApplicationDetailView(viewController: self)
                default:
                    fatalError("센터공고등록 지정되지 않은 화면")
            }
        }
    }
    
    private func setPagesLayoutAndObservable() {
            
        // 레이아웃 설정
        pageViews
            .forEach { page in
                view.addSubview(page)
                page.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    page.topAnchor.constraint(equalTo: statusBar.bottomAnchor),
                    page.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    page.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    page.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                ])
            }
        
        // 첫번째 뷰를 최상단으로
        view.bringSubviewToFront(pageViews.first!)
        
        // 옵저버블 설정
        let nextButtonClickedObservables = pageViews
            .map { $0.nextButtonClicked }
        
        Observable
            .merge(nextButtonClickedObservables)
            .subscribe(onNext: { [weak self] _ in
                self?.next()
            })
            .disposed(by: disposeBag)
        
        let prevButtonClickedObservables = pageViews
            .map { $0.prevButtonClicked }
        
        Observable
            .merge(prevButtonClickedObservables)
            .subscribe(onNext: { [weak self] _ in
                self?.prev()
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
        
        // 로깅
        logCurrentStage()
    }
    
    private func next(animated: Bool = true) {
        
        if let nextStage = RegisterRecruitmentPage(rawValue: currentStage.rawValue+1) {
            
            if nextStage == .overview {
                
                guard let vm = viewModel as? RegisterRecruitmentPostViewModelable else { return }
                
                // 오버뷰화면으로 이동
                vm.showOverView()
                
                return
            }
            
            // Status바 이동
            statusBar.moveToSignal.onNext(.next)
            
            let currentStageIndex: Int = currentStage.stageIndex
            let prevView: UIView? = currentStageIndex != -1 ? pageViews[currentStageIndex] : nil
            let willShowView = pageViews[nextStage.stageIndex]
            
            currentStage = nextStage

            // MARK: Logging stage
            logCurrentStage()
            
            UIView.animate(withDuration: animated ? 0.35 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView?.transform = .init(translationX: -screenWidth, y: 0)
                willShowView.transform = .identity
            }
        }
    }
    
    private func prev(animated: Bool = true) {
        
        if let nextStage = RegisterRecruitmentPage(rawValue: currentStage.rawValue-1) {
            
            // Status바 이동
            statusBar.moveToSignal.onNext(.prev)
            
            let prevView = pageViews[currentStage.stageIndex]
            let willShowView = pageViews[nextStage.stageIndex]
            
            currentStage = nextStage
            
            // MARK: Logging stage
            logCurrentStage()
            
            UIView.animate(withDuration: animated ? 0.35 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView.transform = .init(translationX: screenWidth, y: 0)
                willShowView.transform = .identity
            }
        } else {
            
            // 돌아가기, Coordinator호출
            exitEvent.onNext(())
        }
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        self.viewModel = viewModel
        
        exitEvent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [viewModel] in
                viewModel.exit()
            })
            .disposed(by: disposeBag)
        
        pageViews
            .forEach { view in
                view.bind(viewModel: viewModel)
            }
    }
    
    func logCurrentStage(stage: RegisterRecruitmentPage? = nil) {
        let logObject = CreatePostLogBuilder(
            step: (stage ?? currentStage).step,
            stepName: (stage ?? currentStage).screenKorName
        )
        .build()
        
        logger.send(logObject)
    }
}

protocol RegisterRecruitmentPostViews: UIView, RegisterRecruitmentPostVMBindable {
    var nextButtonClicked: Observable<Void> { get }
    var prevButtonClicked: Observable<Void> { get }
}

extension AddressView: RegisterRecruitmentPostViews { }
