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
    
    typealias NativeCell = WorkerNativeEmployCardCell
    typealias WorknetCell = WorkerWorknetEmployCardCell
    
    // View
    let postTableView = UITableView()
    
    let tableHeader = BoardSortigHeaderView()
    
    // Paging
    var isPaging = true
    
    // Observable
    var postData: [RecruitmentPostForWorkerRepresentable] = []
    let requestNextPage: PublishRelay<Void> = .init()
    
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
        
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.estimatedRowHeight = 218
        postTableView.register(NativeCell.self, forCellReuseIdentifier: NativeCell.identifier)
        postTableView.register(WorknetCell.self, forCellReuseIdentifier: WorknetCell.identifier)
        
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
        
        super.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .postBoardData?
            .drive(onNext: { [weak self] (isRefreshed, cellData) in
                guard let self else { return }
                self.postData = postData
                self.postTableView.reloadData()
                isPaging = false
                
                if isRefreshed {
                    DispatchQueue.main.async { [weak self] in
                        self?.postTableView.setContentOffset(.zero, animated: false)
                    }
                }
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
        
        super.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .postBoardData?
            .drive(onNext: { [weak self] (isRefreshed, cellData) in
                guard let self else { return }
                self.postData = cellData
                self.postTableView.reloadData()
                isPaging = false
                
                if isRefreshed {
                    postTableView.setContentOffset(.zero, animated: false)
                }
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
        postData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        let postData = postData[indexPath.row]
        
        switch postData.postType {
        case .native:
            
            // Cell
            let nativeCell = tableView.dequeueReusableCell(withIdentifier: NativeCell.identifier) as! NativeCell
            
            let postVO = postData as! NativeRecruitmentPostForWorkerVO
            let vm = viewModel as! WorkerEmployCardViewModelable
            let cellVO: WorkerNativeEmployCardVO = .create(vo: postVO)
            nativeCell.bind(
                postId: postVO.postId,
                vo: cellVO,
                viewModel: vm
            )
            cell = nativeCell
        case .workNet:
            
            // Cell
            let workNetCell = tableView.dequeueReusableCell(withIdentifier: WorknetCell.identifier) as! WorknetCell
            
            let postVO = postData as! WorknetRecruitmentPostVO
            let vm = viewModel as! WorkerEmployCardViewModelable
            let cellRO = WorkerWorknetEmployCardRO.create(vo: postVO)
            workNetCell.bind(
                postId: postVO.id,
                ro: cellRO,
                viewModel: vm
            )
            cell = workNetCell
        }
        
        cell.selectionStyle = .none
        
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
