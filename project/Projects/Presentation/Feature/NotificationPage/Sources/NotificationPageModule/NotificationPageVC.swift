//
//  NotificationPageVC.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Entity
import DSKit

import RxSwift
import RxCocoa


public class NotificationPageVC: BaseViewController {
    
    typealias Cell = NotificationCell
    
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
    
    // Init
    
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
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        setUpTableView()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setUpTableView() {
        
        // MARK: DataSource
        tableViewDataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            
            
            return nil
        })
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 93
        tableView.sectionHeaderTopPadding = 10
        
        // MARK: Cell
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
        
        var snapShot = NSDiffableDataSourceSnapshot<Int, String>()
        snapShot.appendSections(SectionInfo.allCases.map({ $0.rawValue }))
        tableViewDataSource.apply(snapShot)
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
}

// MARK: Header
extension NotificationPageVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleText = SectionInfo(rawValue: section)!
        return NotificationSectionHeader(titleText: titleText.korTwoLetterName)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        52
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = DSColor.gray050.color
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case tableView.numberOfSections-1:
            return 0
        default:
            return 8
        }
    }
}
