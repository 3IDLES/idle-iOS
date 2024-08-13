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
    
    var ongoingPostCardVO: Driver<[CenterEmployCardVO]>? { get }
    var requestOngoingPost: PublishRelay<Void> { get }
    
    func createCellVM(vo: CenterEmployCardVO) -> CenterEmployCardViewModelable
}

public class OnGoingPostVC: BaseViewController {
    
    typealias Cell = CenterEmployCardCell
    
    var viewModel: OnGoingPostViewModelable?
    
    // View
    let postTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        return tableView
    }()
    
    let tableHeader = BoardSortigHeaderView()
    
    let ongoingPostCardVO: BehaviorRelay<[CenterEmployCardVO]> = .init(value: [.mock])
    
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
    
    public func bind(viewModel: OnGoingPostViewModelable) {
        
        self.viewModel = viewModel
        
        // Output
        viewModel
            .ongoingPostCardVO?
            .drive(onNext: { [weak self] vos in
                guard let self else { return }
                ongoingPostCardVO.accept(vos)
                postTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // Input
        rx.viewWillAppear
            .map { _ in }
            .bind(to: viewModel.requestOngoingPost)
            .disposed(by: disposeBag)
    }
}

extension OnGoingPostVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ongoingPostCardVO.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        cell.selectionStyle = .none
        
        if let viewModel = self.viewModel {
            let vo = ongoingPostCardVO.value[indexPath.row]
            let vm = viewModel.createCellVM(vo: vo)
            cell.bind(viewModel: vm)
        }
        
        return cell
    }
}

class BoardSortigHeaderView: UIView {
    
    let sortingTypeButton: ImageTextButton = {
        let button = ImageTextButton(
            iconImage: DSKitAsset.Icons.chevronDown.image,
            position: .postfix
        )
        button.label.textString = "정렬 기준"
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setLayout() {
        
        [
            sortingTypeButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            sortingTypeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            sortingTypeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -24),
            sortingTypeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
        ])
    }
}
