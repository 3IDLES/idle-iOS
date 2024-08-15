//
//  IdleTabBar.swift
//  DSKit
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import DSKit

public protocol IdleMainPageItemable: Hashable & CaseIterable {
    var tabItemIcon: UIImage { get }
    var tabItemText: String { get }
    var pageOrderNumber: Int { get }
}

public class IdleTabBar<Item: IdleMainPageItemable>: UIViewController {

    // 탭바구성
    public private(set) var controllers: [Item: UIViewController] = [:]
    public private(set) var items: [Item: IdleTabBarItem] = [:]
    
    // View
    private(set) var displayingVC: UIViewController?
    
    // Observable
    public private(set) var displayingPage: Item?
    
    // 탭바 컨테이너
    private var tabBarItemContainer: IdleTabBarContainer!
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init(
        initialPage: Item,
        info: [PageTabItemInfo]
    ) {

        super.init(nibName: nil, bundle: nil)
        
        setPageControllers(info)
        setPageTabItem()
        
        setAppearance()
        setLayout()
        setObservable()
        
        // 초기세팅
        items[initialPage]?.setState(.accent)
        setPage(page: initialPage)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        view.addSubview(tabBarItemContainer)
        tabBarItemContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBarItemContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarItemContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            tabBarItemContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    private func setObservable() {
        
        let selectionPublishers = items.map { (page: Item, itemView: IdleTabBarItem) in
            itemView.rx.tap.map { _ in page }
        }
        
        Observable
            .merge(selectionPublishers)
            .subscribe(onNext: { [weak self] selectedPage in
                guard let self else { return }
                
                // 선택된 화면 표출
                setPage(page: selectedPage)
                
                // Item들 외향 변경
                items.forEach { (page: Item, itemView: IdleTabBarItem) in
                    
                    itemView.setState(selectedPage == page ? .accent : .idle)
                }
            })
            .disposed(by: disposeBag)
            
    }
}

public extension IdleTabBar {
    
    struct PageTabItemInfo {
        let page: Item
        let navigationController: UINavigationController
        
        public init(page: Item, navigationController: UINavigationController) {
            self.page = page
            self.navigationController = navigationController
        }
    }
    
    /// #1. 현재 컨트롤러에 페이지 컨트롤러들을 세팅합니다.
    private func setPageControllers(_ using: [PageTabItemInfo]) {
        using.forEach { info in
            let controller = info.navigationController
            addChild(controller)
            controller.didMove(toParent: self)
            controllers[info.page] = controller
        }
    }
    
    /// #2. 페이지별 탭바 아이템뷰를 설정합니다.
    private func setPageTabItem() {
        
        let pages = controllers.keys.sorted { $0.pageOrderNumber < $1.pageOrderNumber }
        
        let itemViews = pages.map { page in
            let item = IdleTabBarItem(
                index: page.pageOrderNumber,
                labelText: page.tabItemText,
                image: page.tabItemIcon
            )
            items[page] = item
            return item
        }
        
        tabBarItemContainer = IdleTabBarContainer(
            items: itemViews
        )
    }
    
    /// 해당 함수는 뷰모델에 의해서만 호출됩니다. 특정 페이지를 display합니다.
    private func setPage(page: Item) {
        
        displayingVC?.view.removeFromSuperview()
    
        let willDisplayVC = controllers[page]!
        let willDisplayView = willDisplayVC.view!
        
        view.addSubview(willDisplayView)
        willDisplayView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            willDisplayView.topAnchor.constraint(equalTo: view.topAnchor),
            willDisplayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            willDisplayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            willDisplayView.bottomAnchor.constraint(equalTo: tabBarItemContainer.topAnchor)
        ])
        
        displayingVC = willDisplayVC
    }
}
