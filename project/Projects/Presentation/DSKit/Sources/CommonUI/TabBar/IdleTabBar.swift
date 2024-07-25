//
//  IdleTabBar.swift
//  PresentationCore
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import RxSwift
import RxCocoa

public class IdleTabBar: UIViewController {

    // 탭바구성
    public private(set) var viewControllers: [UIViewController] = []
    private var tabBarItems: [IdleTabBarItem] = []
    
    // 탭바 아이템
    private var tabBarItemViews: [IdleTabBarItemViewable] = []
    
    private var currentIndex: Int = -1
    
    public var selectedIndex: Int {
        get {
            currentIndex
        }
        set {
            moveTo(index: newValue)
            currentIndex = newValue
        }
    }
    
    private let disposeBag = DisposeBag()
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setAppearance()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    /// 생성시 한번만 호출해야 합니다.
    public func setViewControllers(info: [TabBarInfo]) {
        
        viewControllers = []
        tabBarItems = []

        info.forEach {
            viewControllers.append($0.viewController)
            tabBarItems.append($0.tabBarItem)
        }
        
        // 뷰컨트롤러들 추가
        viewControllers
            .forEach {
                self.addChild($0)
                $0.didMove(toParent: self)
            }
        
        setTabBarItems()
    }
    
    private func setTabBarItems() {
        
        tabBarItemViews = tabBarItems.map { item in
            TextButtonType1(labelText: item.name)
        }
        
        let tabBarItemStack = HStack(
            tabBarItemViews,
            alignment: .fill,
            distribution: .fillEqually
        )
        
        view.addSubview(tabBarItemStack)
        tabBarItemStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBarItemStack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            tabBarItemStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarItemStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarItemStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        setTabBarItemObservable()
    }
    
    private func setTabBarItemObservable() {
        
        let observers = tabBarItemViews.enumerated().map { (index, element) in
            element.eventPublisher.map { _ in index }
        }
        
        Observable
            .merge(observers)
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                self?.selectedIndex = index
            })
            .disposed(by: disposeBag)
    }
    
    private func moveTo(index: Int) {
        
        if currentIndex == index { return }
        
        if currentIndex != -1 {
            let prevVC = viewControllers[currentIndex]
            prevVC.view.removeFromSuperview()
        }
        
        let currentVC = viewControllers[index]
        view.addSubview(currentVC.view)
        currentVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        let currentView = currentVC.view!
        
        NSLayoutConstraint.activate([
            currentView.topAnchor.constraint(equalTo: view.topAnchor),
            currentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: ViewController 세팅
    private func setAppearance() {
        
        view.backgroundColor = .white
        view.layoutMargins = .init(top: 0, left: 0, bottom: 56, right: 0)
    }
}

// 임시적 세팅
extension TextButtonType1: IdleTabBarItemViewable { }

// 임시적 세팅
public protocol IdleTabBarItemViewable: UIView {
    var eventPublisher: Observable<UITapGestureRecognizer> { get }
}


public struct IdleTabBarItem {
    let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct TabBarInfo {
    let viewController: UIViewController
    let tabBarItem: IdleTabBarItem
    
    public init(viewController: UIViewController, tabBarItem: IdleTabBarItem) {
        self.viewController = viewController
        self.tabBarItem = tabBarItem
    }
}
