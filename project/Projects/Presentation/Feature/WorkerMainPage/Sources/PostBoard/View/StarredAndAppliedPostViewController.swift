//
//  StarredAndAppliedVC.swift
//  WorkerFeature
//
//  Created by choijunios on 8/16/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

class StarredAndAppliedPostViewController: BaseViewController {
    enum TabBarState: Int, CaseIterable {
        case applied = 0
        case starred = 1
        
        var titleText: String {
            switch self {
            case .applied:
                "지원한 공고"
            case .starred:
                "찜한 공고"
            }
        }
    }
    struct TabBarItem: IdleTabItem {
        var id: TabBarState
        var tabLabelText: String
        
        init(id: TabBarState) {
            self.id = id
            self.tabLabelText = id.titleText
        }
    }
    
    private var currentState: TabBarState = .applied
    private let viewControllerDict: [TabBarState: WorkerPagablePostBoardVC] = [
        .applied : WorkerPagablePostBoardVC(),
        .starred : WorkerPagablePostBoardVC()
    ]
    
    // Init
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        label.textString = "공고 관리"
        return label
    }()
    
    lazy var tabBar: IdleTabControlBar = .init(
        items: TabBarState.allCases.map { TabBarItem(id: $0) },
        initialItem: .init(id: currentState)
    )!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        setAppearance()
        setLayout()
        setObservable()
       
        addViewControllerAndSetLayout(vc: viewControllerDict[currentState]!)
    }
    
    private func setAppearance() {
        view.backgroundColor = DSKitAsset.Colors.gray0.color
    }
    
    private func setLayout() {
        [
            titleLabel,
            tabBar,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            
            tabBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tabBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            tabBar.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    private func setObservable() {
        tabBar
            .statePublisher
            .subscribe(onNext: { [weak self] item in
                self?.showViewController(state: item.id)
            })
            .disposed(by: disposeBag)
    }
    
    private func showViewController(state: TabBarState) {
        
        if currentState == state { return }
        
        // 탭바터치 정지
        tabBar.isUserInteractionEnabled = false
        
        /// viewWillAppear이후에 호출
        let prevViewController = viewControllerDict[currentState]
        let vc = viewControllerDict[state]!
        
        let prevIndex = currentState.rawValue
        let currentIndex = state.rawValue
        
        addViewControllerAndSetLayout(vc: vc)
        
        vc.view.transform = .init(translationX: view.bounds.width * (prevIndex < currentIndex ? 1 : -1), y: 0)
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            
            guard let self else { return }
            
            vc.view.transform = .identity
            prevViewController?.view.transform = .init(translationX: (prevIndex < currentIndex ? -1 : 1) * view.bounds.width, y: 0)
            
        } completion: { [weak self] _ in
            
            prevViewController?.view.removeFromSuperview()
            
            prevViewController?.willMove(toParent: nil)
            prevViewController?.removeFromParent()
            
            self?.currentState = state
            self?.tabBar.isUserInteractionEnabled = true
        }
    }
    
    private func addViewControllerAndSetLayout(vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            vc.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func bind(
        appliedPostVM: AppliedPostBoardViewModel,
        starredPostVM: StarredPostBoardViewModel
    ) {
         
        viewControllerDict[.applied]?.bind(viewModel: appliedPostVM)
        viewControllerDict[.starred]?.bind(viewModel: starredPostVM)
    }
}

