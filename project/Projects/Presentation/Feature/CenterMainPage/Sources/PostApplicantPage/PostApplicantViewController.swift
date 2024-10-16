//
//  CheckApplicantVC.swift
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

class ContentBaseSizeTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {

        return CGSize(width: contentSize.width, height: contentSize.height+self.contentInset.top+self.contentInset.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        invalidateIntrinsicContentSize()
    }
}

class PostApplicantViewController: BaseViewController {
    
    typealias Cell = ApplicantCardCell
    
    // Init
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(titleText: "지원자 확인")
        return bar
    }()
    let postSummaryCard: PostInfoCardView = {
        let view = PostInfoCardView()
        return view
    }()
    
    let applicantTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.textString = "위 공고에 지원한 보호사 목록이에요."
        return label
    }()
    
    let applicantTableView: ContentBaseSizeTableView = {
        let tableView = ContentBaseSizeTableView()
        return tableView
    }()
    
    let postApplicantVO: BehaviorRelay<[PostApplicantVO]> = .init(value: [])
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setLayout()
        setObservable()
        setTableView()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSKitAsset.Colors.gray0.color
    }
    
    private func setLayout() {
        
        let divider = Spacer(height: 8)
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        
        let contentView = UIView()
        contentView.backgroundColor = DSKitAsset.Colors.gray0.color
        
        [
            postSummaryCard,
            
            divider,
            
            applicantTitleLabel,
            applicantTableView,
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            postSummaryCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            postSummaryCard.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            postSummaryCard.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            
            divider.topAnchor.constraint(equalTo: postSummaryCard.bottomAnchor, constant: 20),
            divider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            divider.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            applicantTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            applicantTitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            
            applicantTableView.topAnchor.constraint(equalTo: applicantTitleLabel.bottomAnchor, constant: 20),
            applicantTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            applicantTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            applicantTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.contentInset = .init(
            top: 24,
            left: 0,
            bottom: 20,
            right: 0
        )
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
        ])
        
        [
            navigationBar,
            scrollView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
    
    private func setTableView() {
        applicantTableView.rowHeight = UITableView.automaticDimension
        applicantTableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        applicantTableView.isScrollEnabled = false
        applicantTableView.dataSource = self
        applicantTableView.delegate = self
        applicantTableView.separatorStyle = .none
        applicantTableView.delaysContentTouches = false
    }
    
    private func setObservable() {  }
    
    func bind(viewModel: PostApplicantViewModelable) {
        
        super.bind(viewModel: viewModel)
        
        // Input
        navigationBar
            .backButton.rx.tap
            .bind(to: viewModel.exitButtonClicked)
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map { _ in }
            .bind(to: viewModel.requestpostApplicantVO)
            .disposed(by: disposeBag)
        
        // Output
        viewModel
            .postCardVO?
            .drive(onNext: { [weak self] cardVO in
                self?.postSummaryCard.bind(vo: cardVO)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .postApplicantVO?
            .drive(onNext: { [weak self] vo in
                guard let self else { return }
                postApplicantVO.accept(vo)
                applicantTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        
    }
}

extension PostApplicantViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postApplicantVO.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        
        if let viewModel = self.viewModel as? PostApplicantViewModelable {
            let cellVO = postApplicantVO.value[indexPath.row]
            
            if let cellViewModel = viewModel.createCellViewModel?(cellVO) {
                cell.bind(viewModel: cellViewModel)
                cell.selectionStyle = .none
            }
        }
        
        return cell
    }
}
