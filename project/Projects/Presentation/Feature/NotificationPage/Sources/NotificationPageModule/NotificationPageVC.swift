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
    }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
    }
    
    private func setObservable() {
        
    }
}

extension NotificationPageVC: UITableViewDelegate {
    
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//    }
//    
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//    }
}
