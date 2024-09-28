//
//  ClosedPostVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/13/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift

public protocol ClosedPostViewModelable: BaseViewModel {
    
    var closedPostInfo: RxCocoa.Driver<[RecruitmentPostInfoForCenterVO]>? { get }
    var requestClosedPost: PublishRelay<Void> { get }
    
    func createClosedPostCellVM(postInfo: RecruitmentPostInfoForCenterVO) -> CenterEmployCardViewModelable
}

public class ClosedPostVC: BaseViewController {
    
    typealias Cell = CenterEmployCardCell
    
    // View
    let postTableView: UITableView = .init()
    let tableHeader = BoardSortigHeaderView()
    
    // DataSource
    private var postData: [RecruitmentPostInfoForCenterVO] = []
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
        setTableView()
    }
    
    private func setTableView() {
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.separatorStyle = .none
        postTableView.delaysContentTouches = false
        
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        
        postTableView.tableHeaderView = tableHeader
        
        tableHeader.frame = .init(origin: .zero, size: .init(
            width: view.bounds.width,
            height: 60)
        )
    }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        [
            postTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            postTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind(viewModel: ClosedPostViewModelable) {
        
        // 다수의 화면이 하나의 ViewModel을 공유하는 특수한 경우
        self.viewModel = viewModel
        
        // Output
        viewModel
            .closedPostInfo?
            .drive(onNext: { [weak self] postInfo in
                guard let self else { return }
                
                self.postData = postInfo
                
                postTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // Input
        rx.viewWillAppear
            .map { _ in }
            .bind(to: viewModel.requestClosedPost)
            .disposed(by: disposeBag)
    }
}

extension ClosedPostVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        cell.selectionStyle = .none
        
        let data = postData[indexPath.item]
        
        if let viewModel = self.viewModel as? ClosedPostViewModelable {
            let vm = viewModel.createClosedPostCellVM(postInfo: data)
            cell.bind(viewModel: vm)
        }
        
        return cell
    }
}
