//
//  ChattingListViewController.swift
//  Chatting
//
//  Created by choijunios on 11/4/24.
//

import UIKit

import BaseFeature
import PresentationCore
import DSKit


import RxCocoa
import RxSwift

class ChattingListViewController: BaseViewController {
    
    typealias Cell = ChattingInfoRowCell
    
    // Init
    
    // View
    let chatListView: UITableView = {
        let tableView: UITableView = .init()
        return tableView
    }()
    let navigationBar: IdleNavigationBar = {
        let barView: IdleNavigationBar = .init(titleText: "채팅")
        barView.backButton.isHidden = true
        return barView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        setAppearance()
        setLayout()
    }
    
    private func setTableView() {
        
        chatListView.delegate = self
        chatListView.dataSource = self
        chatListView.rowHeight = 76
        
        // MARK: Cell
        chatListView.separatorStyle = .none
        chatListView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        
        [
            navigationBar,
            chatListView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            chatListView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            chatListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            chatListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            chatListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension ChattingListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 선택된 Cell
    }
}

extension ChattingListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as? Cell else { fatalError() }

        // set initial cell state
        cell.hostImage.backgroundColor = .black
        cell.titleLabel.textString = "세얼간이요양센터"
        cell.latestChattingLabel.textString = "안녕하세요 문의드리고 싶어서 연락드렸어요"
        cell.latestChatDateLabel.textString = "10월 29일"
        cell.unreadChattingCountLabel.textString = "100"
        
        return cell
    }
}

@available(iOS 17, *)
#Preview(traits: .defaultLayout, body: {
    
    ChattingListViewController()
})
