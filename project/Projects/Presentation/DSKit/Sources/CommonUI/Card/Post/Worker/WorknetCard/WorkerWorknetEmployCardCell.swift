//
//  WorkerWorknetEmployCardCell.swift
//  DSKit
//
//  Created by choijunios on 9/6/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class WorkerWorknetEmployCardCell: UITableViewCell {
    
    public static let identifier = String(describing: WorkerWorknetEmployCardCell.self)
    
    private var disposables: [Disposable?]?
    
    let tappableArea: TappableUIView = {
        let view = TappableUIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
        return view
    }()
    let cardView = WorkerWorknetEmployCard()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAppearance()
        setLayout()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func prepareForReuse() {
        disposables?.forEach { $0?.dispose() }
        disposables = nil
    }
    
    func setAppearance() {
        contentView.backgroundColor = .clear
    }
    
    func setLayout() {
        
        tappableArea.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        tappableArea.addSubview(cardView)
        
        
        tappableArea.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tappableArea)

        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.topAnchor),
            cardView.leftAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.leftAnchor),
            cardView.rightAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.rightAnchor),
            cardView.bottomAnchor.constraint(equalTo: tappableArea.layoutMarginsGuide.bottomAnchor),

            tappableArea.topAnchor.constraint(equalTo: contentView.topAnchor),
            tappableArea.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            tappableArea.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            tappableArea.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    public func bind(postId: String, ro: WorkerWorknetEmployCardRO, viewModel: WorkerEmployCardViewModelable) {
        
        // 카드 컨텐츠 바인딩
        cardView.applyRO(ro: ro)
        
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
                    viewModel?.showPostDetail(postType: .workNet, id: postId)
                }),
            
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
