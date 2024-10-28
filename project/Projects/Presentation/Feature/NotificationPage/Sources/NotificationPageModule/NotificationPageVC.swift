//
//  NotificationPageVC.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxSwift
import RxCocoa


protocol NotificationPageViewModelable: BaseViewModel {
    
    // Input
    var viewWillAppear: PublishSubject<Void> { get }
    var exitButtonClicked: PublishSubject<Void> { get }
    
    var requestInitialPageRequest: PublishSubject<Void> { get }
    var requestNextPage: PublishSubject<Void> { get }
    
    // Output
    var tableData: Driver<NotificationTableDataInfo> { get }
    
    /// Cell ViewModel생성
    func createCellVM(vo: NotificationVO) -> NotificationCellViewModel
}

enum SectionInfo: Int, CaseIterable {
    case today
    case week
    case month
    
    var korTwoLetterName: String {
        switch self {
        case .today:
            "오늘"
        case .week:
            "최근 7일"
        case .month:
            "최근 30일"
        }
    }
}


class NotificationPageVC: BaseViewController, UIGestureRecognizerDelegate {
    
    typealias Cell = NotificationCell
    
    // Init
    
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar: IdleNavigationBar = .init(titleText: "알림")
        return bar
    }()
    
    let emptyView: EmptyNotificationPageView = {
        let view: EmptyNotificationPageView = .init(
            titleText: "아직 받은 알림이 없어요.",
            descriptionText: "최근 30 이내의 알림만 확인할 수 있어요."
        )
        view.isHidden = true
        return view
    }()

    var tableViewDataSource: UITableViewDiffableDataSource<Int, String>!
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // Paging
    var tableData: [SectionInfo: [NotificationVO]] = [:]
    let requestNextPage: PublishSubject<Void> = .init()
    var isPaging = true
    
    init(viewModel: NotificationPageViewModelable) {
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel(viewModel: viewModel)
        
        setUpTableView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setUpTableView() {
        
        // MARK: DataSource
        tableViewDataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            
            guard let self else { return Cell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
            
            let viewModel = (viewModel as! NotificationPageViewModelable)
            
            let section = SectionInfo(rawValue: indexPath.section)!
            
            let notificationVO = self.tableData[section]![indexPath.row]
            
            let cellViewModel = viewModel.createCellVM(vo: notificationVO)
            
            cell.selectionStyle = .none
            cell.bind(viewModel: cellViewModel)
            
            return cell
        })
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 102
        tableView.sectionHeaderTopPadding = 10
        // MARK: Cell
        tableView.separatorStyle = .none
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        [
            // zindex순서
            tableView,
            emptyView,
            navigationBar,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setObservable() { }
    
    private func bindViewModel(viewModel: NotificationPageViewModelable) {
        self.bind(viewModel: viewModel)
        
        // Input
        self.rx
            .viewWillAppear
            .map { _ in }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        navigationBar.backButton
            .rx.tap
            .bind(to: viewModel.exitButtonClicked)
            .disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .bind(to: viewModel.requestInitialPageRequest)
            .disposed(by: disposeBag)
        
        requestNextPage
            .bind(to: viewModel.requestNextPage)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .tableData
            .drive(onNext: { [weak self] tableDataInfo in
                
                guard let self else { return }
                
                tableData = tableDataInfo.data
            
                var snapShot: NSDiffableDataSourceSnapshot<Int, String> = .init()
                
                snapShot.appendSections(SectionInfo.allCases.map({ $0.rawValue }))
                
                tableData.forEach { (section, items) in
                    let itemIds = items.map({ $0.id })
                    snapShot.appendItems(itemIds, toSection: section.rawValue)
                }
                
                tableViewDataSource.apply(snapShot, animatingDifferences: false)
                
                // MARK: 테이블이 리프래쉬 된 경우, 스크롤을 최상단으로 이동
                if tableDataInfo.isRefreshed {
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.setContentOffset(.zero, animated: false)
                    }
                }
                
                // MARK: 알림이 없는 경우 빈화면 UI표시
                emptyView.isHidden = tableData.count != 0
                
                // 페이징 작업 종료
                isPaging = false
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Header
extension NotificationPageVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleText = SectionInfo(rawValue: section)!
        return NotificationSectionHeader(titleText: titleText.korTwoLetterName)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        52
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = DSColor.gray050.color
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case tableView.numberOfSections-1:
            return 0
        default:
            return 8
        }
    }
}

// MARK: ScrollView관련
extension NotificationPageVC {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 스크롤이 테이블 뷰 Offset의 끝에 가게 되면 다음 페이지를 호출
        if offsetY > (contentHeight - height) {
            if !isPaging {
                isPaging = true
                requestNextPage.onNext(())
            }
        }
    }
}
