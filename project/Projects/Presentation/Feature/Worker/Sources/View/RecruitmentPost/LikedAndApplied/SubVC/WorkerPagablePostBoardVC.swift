//
//  WorkerPagablePostBoardVC.swift
//  WorkerFeature
//
//  Created by choijunios on 8/16/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class WorkerPagablePostBoardVC: BaseViewController {
    
    typealias Cell = WorkerNativeEmployCardCell
    
    var viewModel: WorkerPagablePostBoardVMable?
    
    // View
    let postTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        return tableView
    }()
    
    let tableHeader = BoardSortigHeaderView()
    
    // Paging
    var isPaging = true
    
    // Observable
    let cellData: BehaviorRelay<[PostBoardCellData]> = .init(value: [])
    let requestNextPage: PublishRelay<Void> = .init()
    
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
    
    func bind(viewModel: WorkerPagablePostBoardVMable) {
        
        self.viewModel = viewModel
        
        // 로딩 바인딩
        super.bind(viewModel: viewModel, disposeBag: disposeBag)
        
        // Output
        viewModel
            .postBoardData?
            .drive(onNext: { [weak self] (isRefreshed, cellData) in
                guard let self else { return }
                self.cellData.accept(cellData)
                self.postTableView.reloadData()
                
                if isRefreshed {
                    DispatchQueue.main.async { [weak self] in
                        self?.postTableView.setContentOffset(.zero, animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .alert?
            .drive(onNext: { [weak self] alertVO in
                self?.showAlert(vo: alertVO)
            })
            .disposed(by: disposeBag)
        
        // Input
        Observable
            .merge(self.rx.viewWillAppear.map { _ in () })
            .bind(to: viewModel.requestInitialPageRequest)
            .disposed(by: disposeBag)
        
        self.requestNextPage
            .bind(to: viewModel.requestNextPage)
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: WorkerAppliablePostBoardVMable) {
        
        self.viewModel = viewModel
        
        // 로딩 바인딩
        super.bind(viewModel: viewModel, disposeBag: disposeBag)
        
        // Output
        viewModel
            .postBoardData?
            .drive(onNext: { [weak self] (isRefreshed, cellData) in
                guard let self else { return }
                self.cellData.accept(cellData)
                self.postTableView.reloadData()
                
                if isRefreshed {
                    postTableView.setContentOffset(.zero, animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel
            .alert?
            .drive(onNext: { [weak self] alertVO in
                self?.showAlert(vo: alertVO)
            })
            .disposed(by: disposeBag)
        
        // Input
        Observable
            .merge(self.rx.viewWillAppear.map { _ in () })
            .bind(to: viewModel.requestInitialPageRequest)
            .disposed(by: disposeBag)
        
        self.requestNextPage
            .bind(to: viewModel.requestNextPage)
            .disposed(by: disposeBag)
    }
}

extension WorkerPagablePostBoardVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        cell.selectionStyle = .none
        
        let cellData = cellData.value[indexPath.row]
        
        if let vm = viewModel {
            cell.bind(postId: cellData.postId, vo: cellData.cardVO, viewModel: vm)
        }
        
        return cell
    }
}

// MARK: ScrollView관련
extension WorkerPagablePostBoardVC {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 스크롤이 테이블 뷰 Offset의 끝에 가게 되면 다음 페이지를 호출
        if offsetY > (contentHeight - height) {
            if !isPaging {
                isPaging = true
                requestNextPage.accept(())
            }
        }
    }
}
