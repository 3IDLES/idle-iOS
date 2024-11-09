//
//  WorkerRecruitmentPostBoardVC.swift
//  WorkerFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import BaseFeature
import PresentationCore
import Domain
import DSKit


import RxCocoa
import RxSwift


class MainPostBoardViewController: BaseViewController {
    typealias NativeCell = WorkerNativeEmployCardCell
    typealias WorknetCell = WorkerWorknetEmployCardCell
    
    // View
    fileprivate let topContainer: WorkerMainTopView = {
        let container = WorkerMainTopView(innerViews: [])
        return container
    }()
    let postTableView = UITableView()
    let tableHeader = BoardSortigHeaderView()
    let emptyScreen: WorkerBoardEmptyView = {
        let view = WorkerBoardEmptyView()
        view.isHidden = true
        return view
    }()
    
    // Paging
    var isPaging = true
    
    // Observable
    var postData: [RecruitmentPostForWorkerRepresentable] = []
    let requestNextPage: PublishRelay<Void> = .init()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setLayout()
    }
    
    func bind(viewModel: WorkerRecruitmentPostBoardVMable) {
        
        super.bind(viewModel: viewModel)
        
        // Output
        viewModel
            .workerLocationTitleText?
            .drive(onNext: { [weak self] titleText in
                self?.topContainer.locationLabel.textString = titleText
            })
            .disposed(by: disposeBag)
        
        viewModel
            .postBoardData?
            .drive(onNext: { [weak self] (isRefreshed: Bool, postData) in
                guard let self else { return }
                
                self.postData = postData
                
                postTableView.reloadData()
                isPaging = false
                
                if isRefreshed {
                    DispatchQueue.main.async { [weak self] in
                        self?.postTableView.setContentOffset(.zero, animated: false)
                    }
                }
                
                postTableView.layoutIfNeeded()
                if self.checkScrollViewHasSpace() {
                    // 빈공간이 있는 경우 바로 다음요청
                    requestNextPage.accept(())
                }
                
                
                // 공고가 없을 경우
                emptyScreen.isHidden = (postData.count != 0)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .idleAlertVM?
            .drive(onNext: { [weak self] vm in
                self?.showIdleModal(type: .orange, viewModel: vm)
            })
            .disposed(by: disposeBag)
        
        // Input
        self.emptyScreen
            .editProfile.rx.tap
            .bind(to: viewModel.editProfileButtonClicked)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.requestWorkerLocation)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.requestInitialPageRequest)
            .disposed(by: disposeBag)
        
        self.requestNextPage
            .bind(to: viewModel.requestNextPage)
            .disposed(by: disposeBag)
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
    
    private func setLayout() {
        
        [
            topContainer,
            postTableView,
            emptyScreen,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            postTableView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            postTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            postTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyScreen.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            emptyScreen.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            emptyScreen.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            emptyScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
    
    func checkScrollViewHasSpace() -> Bool {
        postTableView.contentSize.height < postTableView.frame.height
    }
}

extension MainPostBoardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
extension MainPostBoardViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
