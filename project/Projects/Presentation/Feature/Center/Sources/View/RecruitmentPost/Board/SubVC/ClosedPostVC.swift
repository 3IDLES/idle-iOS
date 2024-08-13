//
//  ClosedPostVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/13/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public protocol ClosedPostViewModelable {
    
    var closedPostCardVO: Driver<[CenterEmployCardVO]>? { get }
    var requestClosedPost: PublishRelay<Void> { get }
}

public class ClosedPostVC: BaseViewController {
    
    typealias Cell = CenterEmployCardCell
    
    // View
    let postTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        return tableView
    }()
    
    let tableHeader = BoardSortigHeaderView()
    
    let closedPostCardVO: BehaviorRelay<[CenterEmployCardVO]> = .init(value: [])
    
    // Observable
    private let disposeBag = DisposeBag()
    
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
        
        // Output
        viewModel
            .closedPostCardVO?
            .drive(onNext: { [weak self] vos in
                guard let self else { return }
                closedPostCardVO.accept(vos)
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
        closedPostCardVO.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        let vo = closedPostCardVO.value[indexPath.row]
        let vm = CenterEmployCardVM(vo: vo)
        cell.bind(viewModel: vm)
        cell.selectionStyle = .none
        return cell
    }
}
