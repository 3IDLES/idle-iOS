//
//  CenterCertificateIntroductionVC.swift
//  CenterFeature
//
//  Created by choijunios on 9/8/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import BaseFeature

public class CenterCertificateIntroductionVC: BaseViewController {
    
    // Init
    
    // View
    let dotView = PageControllerDotView(pageCnt: 3)
    
    let logoutButton: TextButtonType3 = {
        let button = TextButtonType3(typography: .Body3)
        button.textString = "로그아웃"
        button.attrTextColor = DSColor.gray300.color
        return button
    }()
    
    let pageViewController: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        return vc
    }()
    
    let requestAuthButton: IdlePrimaryButton = {
        let button = IdlePrimaryButton(level: .large)
        button.label.textString = "인증 요청하기"
        button.isUserInteractionEnabled = false
        return button
    }()
    
    // Paging
    private var pages: [UIViewController] = []
    private var currentPageIndex: Int = 0
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setLayout()
        setPageController()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setPageController() {
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        self.pages = [
            ("센터 관리자 인증 시", "요양보호사 정보를\n한눈에 확인할 수 있어요", CenterFeatureAsset.workerProfileOnboarding.image),
            ("센터 관리자 인증 시", "요양보호사 구인 공고를\n간편하게 등록할 수 있어요", CenterFeatureAsset.postRegisterOnboarding.image),
            ("센터 관리자 인증 시", "요양보호사를 즐겨찾기하고\n직접 연락해 능동적으로 구인해요", CenterFeatureAsset.favoriteWorkerOnboarding.image),
        ].map { (text1, text2, image) in
            let vc = CenterCertificateIntroductionSubVC(
                title1Text: text1,
                title2Text: text2,
                image: image
            )
            vc.willMove(toParent: pageViewController)
            pageViewController.addChild(vc)
            return vc
        }
        
        let firstPage = pages.first!
        
        pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
        dotView.activateView(0)
        currentPageIndex = 0
    }
    
    private func setLayout() {
        
        pageViewController.willMove(toParent: self)
        addChild(pageViewController)
        logoutButton.sizeToFit()
        
        let logoutSpacer = Spacer(width: logoutButton.bounds.width)
        let topContainer = HStack([
            logoutSpacer,
            dotView,
            logoutButton,
        ], alignment: .center, distribution: .equalSpacing)
        
        let pageControllerView = pageViewController.view!
        [
            topContainer,
            pageControllerView,
            requestAuthButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 29.5),
            topContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 35),
            topContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -35),
            
            pageControllerView.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 28),
            pageControllerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            pageControllerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            pageControllerView.bottomAnchor.constraint(equalTo: requestAuthButton.topAnchor, constant: -20),
            
            requestAuthButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            requestAuthButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            requestAuthButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
        ])
    }
    
    private func setObservable() {
        
    }
    
    func bind(viewModel: CenterCertificateIntroVM) {
        
        super.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .currentStatus?
            .drive(onNext: { [weak self] status in
                
                guard let self else { return }
                
                switch status {
                case .new:
                    canRequestJoinState()
                case .pending:
                    alreadyRequestJoin()
                case .approved:
                    return
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .certificateRequestSuccess?
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                
                alreadyRequestJoin()
            })
            .disposed(by: disposeBag)
        
        // Input
        // - request status
        
        Observable
            .merge(
                rx.viewDidLoad.asObservable(),
                NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).map {_ in }
            )
            .bind(to: viewModel.requestCurrentStatus)
            .disposed(by: disposeBag)
        
        logoutButton
            .eventPublisher
            .bind(to: viewModel.logoutButtonClicked)
            .disposed(by: disposeBag)
        
        requestAuthButton
            .rx.tap
            .bind(to: viewModel.certificateRequestButtonClicked)
            .disposed(by: disposeBag)
    }
    
    func canRequestJoinState() {
        requestAuthButton.setEnabled(true)
        requestAuthButton.label.textString = "인증 요청하기"
    }
    
    func alreadyRequestJoin() {
        requestAuthButton.setEnabled(false)
        requestAuthButton.label.textString = "관리자 인증 요청 중이에요"
    }
}

extension CenterCertificateIntroductionVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextIndex = (currentPageIndex+1) % pages.count
        return pages[nextIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let nextIndex = (currentPageIndex-1) % pages.count
        return nextIndex >= 0 ? pages[nextIndex] : nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let visibleViewController = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: visibleViewController) else {
                return
            }
            currentPageIndex = index
            dotView.activateView(index)
        }
}

class PageControllerDotView: HStack {
    
    let accentColor = DSColor.orange500.color
    let normalColor = DSColor.gray100.color
    
    // Init
    let pageCnt: Int
    
    // View
    private var dotViews: [Int: UIView] = [:]
    
    init(pageCnt: Int) {
        self.pageCnt = pageCnt
        super.init([], spacing: 12)
        setLayout()
    }
    required init(coder: NSCoder) { fatalError() }
    
    func setLayout() {
        
        let viewList = (0..<pageCnt).map { index in
            let view = Spacer(width: 8, height: 8)
            view.backgroundColor = normalColor
            view.layer.cornerRadius = 4
            
            dotViews[index] = view
            
            return view
        }
        
        viewList.forEach {
            self.addArrangedSubview($0)
        }
    }
    
    func activateView(_ index: Int) {
        
        dotViews.forEach { (key, view) in

            view.backgroundColor = key == index ? accentColor : normalColor
         }
    }
}
