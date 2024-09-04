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

public protocol RegisterRecruitmentPostVMBindable {
    func bind(viewModel: RegisterRecruitmentPostViewModelable)
}

public protocol RegisterRecruitmentPostViewModelable:
    
    // 수정화면 요구사항
    EditPostViewModelable,

    // 오버뷰 화면 요구 사항
    PostOverviewViewModelable
{
    /// 코디네이터
    var registerRecruitmentPostCoordinator: RegisterRecruitmentPostCoordinatable? { get }
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
                    WorkTimeAndPayView()
                case .workPlaceAddress:
                    AddressView(viewController: self)
                case .customerInformation:
                    CustomerInformationView()
                case .customerRequirement:
                    CustomerRequirementView()
                case .additionalInfo:
                    ApplicationDetailView(viewController: self)
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
        
        if let nextIndex = RegisterRecruitmentPage(rawValue: currentIndex+1)?.rawValue {
            
            // Status바 이동
            statusBar.moveToSignal.onNext(.next)
            
            let prevView: UIView? = currentIndex != -1 ? pageViews[currentIndex] : nil
            let willShowView = pageViews[nextIndex]
            
            currentIndex = nextIndex
            
            UIView.animate(withDuration: animated ? 0.35 : 0.0) { [screenWidth, prevView, willShowView] in
                
                prevView?.transform = .init(translationX: -screenWidth, y: 0)
                willShowView.transform = .identity
            }
        } else {
            
            guard let vm = viewModel as? RegisterRecruitmentPostViewModelable else { return }
            
            // 오버뷰화면으로 이동
            vm.registerRecruitmentPostCoordinator?.showOverViewScreen()
        }
    }
    
    private func prev(animated: Bool = true) {
        if let nextIndex = RegisterRecruitmentPage(rawValue: currentIndex-1)?.rawValue {
            
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
            
            guard let vm = viewModel as? RegisterRecruitmentPostViewModelable else { return }
            
            // 돌아가기, Coordinator호출
            vm.registerRecruitmentPostCoordinator?.registerFinished()
        }
    }
    
    public func bind(viewModel: RegisterRecruitmentPostViewModelable) {
        
        self.viewModel = viewModel
        
        pageViews
            .forEach { view in
                view.bind(viewModel: viewModel)
            }
    }
}

protocol RegisterRecruitmentPostViews: UIView, RegisterRecruitmentPostVMBindable {
    var ctaButton: CTAButtonType1 { get }
}

extension AddressView: RegisterRecruitmentPostViews { }
