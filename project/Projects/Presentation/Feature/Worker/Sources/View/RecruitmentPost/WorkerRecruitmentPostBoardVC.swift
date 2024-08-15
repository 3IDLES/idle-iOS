//
//  WorkerRecruitmentPostBoardVC.swift
//  WorkerFeature
//
//  Created by choijunios on 8/15/24.
//

import UIKit
import BaseFeature
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class WorkerRecruitmentPostBoardVC: BaseViewController {
    typealias Cell = WorkerEmployCardCell
    
    var viewModel: WorkerRecruitmentPostBoardVMable?
    
    // View
    let topContainer: WorkerMainTopContainer = {
        let container = WorkerMainTopContainer(innerViews: [])
        return container
    }()
    let postTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        return tableView
    }()
    
    let tableHeader = BoardSortigHeaderView()
    
    let ongoingPostCardVO: BehaviorRelay<[WorkerEmployCardVO]> = .init(value: [])
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setLayout()
    }
    
    public func bind(viewModel: WorkerRecruitmentPostBoardVMable) {
        
        self.viewModel = viewModel
        
        topContainer.locationLabel.textString = "서울시 영등포구(미구현)"
        
        // Output
        viewModel
            .ongoingPostCardVO?
            .drive(ongoingPostCardVO)
            .disposed(by: disposeBag)
        
        // Input
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
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
    
    private func setLayout() {
        
        [
            topContainer,
            postTableView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            topContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            postTableView.topAnchor.constraint(equalTo: topContainer.bottomAnchor),
            postTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            postTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        
    }
}

extension WorkerRecruitmentPostBoardVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ongoingPostCardVO.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        cell.selectionStyle = .none
        
        // MARK: TODO: PostId를 가져오기
        
        if let viewModel = self.viewModel {
            let vo = ongoingPostCardVO.value[indexPath.row]
            let vm = viewModel.createCellVM(
                postId: "00-00000-00000",
                vo: vo
            )
            cell.bind(viewModel: vm)
        }
        
        return cell
    }
}

// MARK: Top Container
class WorkerMainTopContainer: UIView {
    
    // Init parameters
    
    // View
    
    lazy var locationLabel: IdleLabel = {
        
        let label = IdleLabel(typography: .Heading1)
        label.textAlignment = .left
        return label
    }()
    
    let locationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DSIcon.location.image
        imageView.tintColor = DSColor.gray700.color
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    
    init(
        titleText: String = "",
        innerViews: [UIView]
    ) {
        super.init(frame: .zero)
        
        self.locationLabel.textString = titleText
        
        setApearance()
        setAutoLayout(innerViews: innerViews)
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        
    }
    
    private func setAutoLayout(innerViews: [UIView]) {
        
        self.layoutMargins = .init(
            top: 20.43,
            left: 20,
            bottom: 8,
            right: 20
        )
        
        let mainStack = HStack(
            [
                [
                    locationImage,
                    Spacer(width: 4),
                    locationLabel,
                    Spacer(),
                ],
                innerViews
            ].flatMap { $0 },
            alignment: .center,
            distribution: .fill
        )
        
        [
            mainStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            locationImage.widthAnchor.constraint(equalToConstant: 32),
            locationImage.heightAnchor.constraint(equalTo: locationImage.widthAnchor),
            
            mainStack.leftAnchor.constraint(equalTo: self.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: self.layoutMarginsGuide.rightAnchor),
            mainStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])

    }
}
