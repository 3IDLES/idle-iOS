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
        tableViewDataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            return nil
        })
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 93
        tableView.sectionHeaderTopPadding = 0
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
    
    private func setObservable() {
        
    }
}

extension NotificationPageVC: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleText = SectionInfo(rawValue: section)!
        return NotificationSectionHeader(titleText: titleText.korTwoLetterName)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        62
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = DSColor.gray050.color
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 2:
            return 0
        default:
            return 8
        }
    }
}

class NotificationSectionHeader: UIView {
    
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        return label
    }()
    
    init(titleText: String) {
        self.titleLabel.textString = titleText
        super.init(frame: .zero)
        
        setUpUI()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setUpUI() {
        
        [
            titleLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ])
    }
}
