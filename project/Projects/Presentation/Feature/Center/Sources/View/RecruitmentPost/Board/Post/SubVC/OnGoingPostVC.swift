//
//  OnGoingPostVC.swift
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

public protocol OnGoingPostViewModelable {
    
    var ongoingPostInfo: Driver<[RecruitmentPostInfoForCenterVO]>? { get }
    var showRemovePostAlert: Driver<IdleAlertViewModelable>? { get }
    
    var requestOngoingPost: PublishRelay<Void> { get }
    var registerPostButtonClicked: PublishRelay<Void> { get }

    func createOngoingPostCellVM(postInfo: RecruitmentPostInfoForCenterVO) -> CenterEmployCardViewModelable
}

public class OnGoingPostVC: BaseViewController {
    
    typealias Cell = CenterEmployCardCell
    
    var viewModel: OnGoingPostViewModelable?
    
    // View
    let postTableView: UITableView = .init()
    let tableHeader = BoardSortigHeaderView()
    
    let registerPostButton: IdleFloatingButton = {
        let button = IdleFloatingButton(labelText: "공고 등록")
        return button
    }()
    
    // DataSource
    private var postData: [RecruitmentPostInfoForCenterVO] = []
    
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
            postTableView,
            registerPostButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            postTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            registerPostButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            registerPostButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind(viewModel: OnGoingPostViewModelable) {
        
        self.viewModel = viewModel
        
        // Output
        viewModel
            .ongoingPostInfo?
            .drive(onNext: { [weak self] postInfo in
                guard let self else { return }
                
                self.postData = postInfo
                
                postTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .showRemovePostAlert?
            .drive(onNext: { [weak self] vm in
                self?.showIdleModal(viewModel: vm)
            })
            .disposed(by: disposeBag)
        
        // Input
        rx.viewWillAppear
            .map { _ in }
            .bind(to: viewModel.requestOngoingPost)
            .disposed(by: disposeBag)
        
        registerPostButton
            .rx.tap
            .bind(to: viewModel.registerPostButtonClicked)
            .disposed(by: disposeBag)
            
    }
}

extension OnGoingPostVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        cell.selectionStyle = .none
        
        let data = postData[indexPath.item]
        
        if let viewModel = self.viewModel {
            let vm = viewModel.createOngoingPostCellVM(postInfo: data)
            cell.bind(viewModel: vm)
        }
        
        return cell
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if registerPostButton.alpha != 0 {
            UIView.animate(withDuration: 0.1) {
                self.registerPostButton.alpha = 0.5
            }
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if registerPostButton.alpha != 1 {
            UIView.animate(withDuration: 0.1) {
                self.registerPostButton.alpha = 1
            }
        }
    }
}
