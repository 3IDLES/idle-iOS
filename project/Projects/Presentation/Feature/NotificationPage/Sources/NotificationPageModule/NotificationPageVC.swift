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
    
    // Output
    var tableData: Driver<(Bool, [SectionInfo : [NotificationVO]])>? { get }
    
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


class NotificationPageVC: BaseViewController {
    
    typealias Cell = NotificationCell
    
    // Init
    
    
    // Table Data
    private var tableData: [SectionInfo: [NotificationVO]] = [:]
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar: IdleNavigationBar = .init(titleText: "알림")
        return bar
    }()

    var tableViewDataSource: UITableViewDiffableDataSource<Int, String>!
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
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
        tableView.estimatedRowHeight = 93
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
            navigationBar,
            tableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        
        // Output
        viewModel
            .tableData?
            .drive(onNext: { [weak self] (isFirst, tableData) in
                
                guard let self else { return }
                
                self.tableData = tableData
            
                var snapShot: NSDiffableDataSourceSnapshot<Int, String> = .init()
                
                snapShot.appendSections(SectionInfo.allCases.map({ $0.rawValue }))
                
                tableData.forEach { (section, items) in
                    let itemIds = items.map({ $0.id })
                    snapShot.appendItems(itemIds, toSection: section.rawValue)
                }
                
                tableViewDataSource.apply(snapShot, animatingDifferences: !isFirst)
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
