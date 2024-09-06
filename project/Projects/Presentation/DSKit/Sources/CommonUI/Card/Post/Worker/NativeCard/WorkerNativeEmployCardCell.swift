//
//  WorkerNativeEmployCardCell.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public enum PostAppliedState {
    case applied
    case notApplied
}

public protocol WorkerNativeEmployCardViewModelable: AnyObject {
    
    /// '지원하기' 버튼이 눌렸을 때, 공고 id를 전달합니다.
    var applyButtonClicked: PublishRelay<(postId: String, postTitle: String)> { get }
    
    /// 공고상세보기
    func showPostDetail(id: String)
    
    /// 즐겨찾기 버튼 클릭
    func setPostFavoriteState(isFavoriteRequest: Bool, postId: String, postType: RecruitmentPostType) -> Single<Bool>
}

public class WorkerNativeEmployCardCell: UITableViewCell {
    
    public static let identifier = String(describing: WorkerNativeEmployCardCell.self)
    
    
    var viewModel: WorkerNativeEmployCardViewModelable?
    private var disposables: [Disposable?]?
    
    // View
    let tappableArea: TappableUIView = {
        let view = TappableUIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        return view
    }()
    let cardView = WorkerNativeEmployCard()
    let applyButton: IdlePrimaryCardButton = {
        let btn = IdlePrimaryCardButton(level: .large)
        btn.label.textString = "지원하기"
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        viewModel = nil
        
        disposables?.forEach { $0?.dispose() }
        disposables = nil
    }
    
    func setAppearance() {
        
    }
    
    func setLayout() {
        
        let mainStack = VStack([cardView, applyButton], spacing: 8, alignment: .fill)
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        
        tappableArea.addSubview(mainStack)
        tappableArea.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        [
            tappableArea
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            applyButton.heightAnchor.constraint(equalToConstant: 44),
            
            mainStack.topAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.topAnchor),
            mainStack.leftAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.leftAnchor),
            mainStack.rightAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.rightAnchor),
            mainStack.bottomAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.bottomAnchor),

            tappableArea.topAnchor.constraint(equalTo: contentView.topAnchor),
            tappableArea.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            tappableArea.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            tappableArea.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    public func bind(postId: String, vo: WorkerNativeEmployCardVO, viewModel: WorkerNativeEmployCardViewModelable) {
        
        // 지원 여부
        if let appliedDate = vo.applyDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "지원완료 yyyy. MM. dd"
            let applyButtonLabelString = dateFormatter.string(from: appliedDate)
            applyButton.label.textString = applyButtonLabelString
            applyButton.setEnabled(false)
        }
        
        // 카드 컨텐츠 바인딩
        let cardRO = WorkerNativeEmployCardRO.create(vo: vo)
        cardView.bind(ro: cardRO)
        
        let starButton = cardView.starButton
        
        let favoriteRequestResult = starButton
            .onTapEvent
            .map { state in
                // normal인 경우 true / 즐겨찾기 요청
                state == .normal
            }
            .flatMap { [viewModel] isFavoriteRequest in
                viewModel.setPostFavoriteState(
                    isFavoriteRequest: isFavoriteRequest,
                    postId: postId,
                    postType: .native
                )
            }
        
        // input
        let disposables: [Disposable?] = [

            // Input
            tappableArea
                .rx.tap
                .subscribe(onNext: { [weak viewModel] _ in
                    viewModel?.showPostDetail(id: postId)
                }),
                        
            applyButton.rx.tap
                .map({ _ in (postId, vo.title) })
                .bind(to: viewModel.applyButtonClicked),
            
            favoriteRequestResult
                .subscribe(onNext: { [starButton] isSuccess in
                    
                    if isSuccess {
                        
                        // 성공시 상태변경
                        starButton.toggle()
                    }
                })
        ]
        
        self.disposables = disposables
    }
}
