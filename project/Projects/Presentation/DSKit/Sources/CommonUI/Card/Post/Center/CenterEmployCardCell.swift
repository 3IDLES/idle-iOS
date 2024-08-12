//
//  CenterEmployCardCell.swift
//  DSKit
//
//  Created by choijunios on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class CenterEmployCardCell: UITableViewCell {
    
    let tappableArea: TappableUIView = .init()
    
    let cardView = CenterEmployCard()
    
    private var disposables: [Disposable?]?
    
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
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 12
        contentView.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
    }
    
    func setLayout() {
        
        [
            cardView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            cardView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    public func binc(viewModel: CenterEmployCardViewModelable) {
        
        let disposables: [Disposable?] = [
            // Output
            viewModel
                .renderObject?
                .drive(onNext: { [cardView] ro in
                    cardView.binc(ro: ro)
                }),
            
            // Input
            cardView.rx.tap
                .bind(to: viewModel.postCardClicked),
            
            cardView.checkApplicantsButton
                .rx.tap
                .bind(to: viewModel.checkApplicantBtnClicked),
            
            cardView.editPostButton
                .rx.tap
                .bind(to: viewModel.editPostBtnClicked),
                
            cardView.terminatePostButton
                .rx.tap
                .bind(to: viewModel.terminatePostBtnClicked),
        ]
        
        self.disposables = disposables
        
        (viewModel as? TextVM)?.publishObect.accept(.mock)
    }
}

fileprivate class TextVM: CenterEmployCardViewModelable {

    public let publishObect: PublishRelay<CenterEmployCardRO> = .init()
    
    var renderObject: RxCocoa.Driver<CenterEmployCardRO>?
    
    var postCardClicked: RxRelay.PublishRelay<Void> = .init()
    var checkApplicantBtnClicked: RxRelay.PublishRelay<Void> = .init()
    var editPostBtnClicked: RxRelay.PublishRelay<Void> = .init()
    var terminatePostBtnClicked: RxRelay.PublishRelay<Void> = .init()
    
    init() {
        
        renderObject = publishObect.asDriver(onErrorJustReturn: .mock)
    }
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    let btn = CenterEmployCard()
    let vm = TextVM()
    
    return btn
}
