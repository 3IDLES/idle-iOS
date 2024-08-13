//
//  CheckApplicantVC.swift
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

class MyTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {

        return CGSize(width: contentSize.width, height: contentSize.height+self.contentInset.top+self.contentInset.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        invalidateIntrinsicContentSize()
    }
}

public protocol CheckApplicantViewModelable {
    // Input
    var requestpostApplicantVO: PublishRelay<Void> { get }
    
    // Output
    var postApplicantVO: Driver<[PostApplicantVO]>? { get }
    var postCardVO: CenterEmployCardVO { get }
    var alert: Driver<DefaultAlertContentVO>? { get }
}

public class CheckApplicantVC: BaseViewController {
    
    typealias Cell = ApplicantCardCell
    
    var viewModel: CheckApplicantViewModelable?
    
    // Init
    
    // View
    let navigationBar: NavigationBarType1 = {
        let view = NavigationBarType1(navigationTitle: "지원자 확인")
        return view
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
    
    let applicantTableView: MyTableView = {
        let tableView = MyTableView()
        return tableView
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    let postApplicantVO: BehaviorRelay<[PostApplicantVO]> = .init(value: [])
    
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
            
            applicantTitleLabel.topAnchor.constraint(equalTo: divider.topAnchor, constant: 20),
            applicantTitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            
            applicantTableView.topAnchor.constraint(equalTo: applicantTitleLabel.bottomAnchor, constant: 20),
            applicantTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            applicantTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            applicantTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.contentInset = .init(
            top: 36,
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
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            
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
    
    public func bind(viewModel: CheckApplicantViewModelable) {
        
        self.viewModel = viewModel
        
        postSummaryCard
            .bind(vo: viewModel.postCardVO)
        
        viewModel
            .postApplicantVO?
            .drive(onNext: { [weak self] vo in
                guard let self else { return }
                postApplicantVO.accept(vo)
                applicantTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        rx.viewWillAppear
            .map { _ in }
            .bind(to: viewModel.requestpostApplicantVO)
            .disposed(by: disposeBag)
    }
}

extension CheckApplicantVC: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postApplicantVO.value.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        let vm = ApplicantCardVM(vo: postApplicantVO.value[indexPath.row])
        cell.bind(viewModel: vm)
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: ApplicantCardVM
public class ApplicantCardVM: ApplicantCardViewModelable {
    
    // Init
    let id: String
    
    public var showProfileButtonClicked: PublishRelay<Void> = .init()
    public var employButtonClicked: PublishRelay<Void> = .init()
    public var staredThisWorker: PublishRelay<Bool> = .init()
    
    public var renderObject: Driver<ApplicantCardRO>?
    
    public init(vo: PostApplicantVO) {
        self.id = vo.workerId
        
        // MARK: RenderObject
        let publishRelay: BehaviorRelay<ApplicantCardRO> = .init(value: .mock)
        renderObject = publishRelay.asDriver(onErrorJustReturn: .mock)
        
        publishRelay.accept(ApplicantCardRO.create(vo: vo))
        
        // MARK: 버튼 처리
    }
}
